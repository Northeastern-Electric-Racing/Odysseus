use clap::Parser;
use russh::{
    ChannelMsg,
    client::{self},
    keys::PublicKey,
};
use russh_sftp::client::SftpSession;
use std::{sync::Arc, time::Duration};
use tokio::io::AsyncWriteExt;
use tokio::net::ToSocketAddrs;
// READ ME
// Adding a new package:
// 1. Add to Packages enum
// 2. All Match compiler errors, add items as appropriate
//

#[derive(clap::ValueEnum, Clone, Debug, Default)]
enum Devices {
    #[default]
    Tpu,
    Wheel,
    TpuCm5,
    ApPi5,
    Iroh,
}

impl Devices {
    const fn get_defconfig(&self) -> &'static str {
        match self {
            Devices::Tpu => "tpu",
            Devices::Wheel => "wheel-cm5",
            Devices::TpuCm5 => "tpu-cm5",
            Devices::ApPi5 => "ap-pi5",
            Devices::Iroh => "iroh",
        }
    }

    fn get_ipaddr(&self) -> &'static str {
        match self {
            Devices::Tpu => "192.168.100.12:22",
            Devices::Wheel => "192.168.100.14:22",
            Devices::TpuCm5 => "192.168.100.12:22",
            Devices::ApPi5 => "192.168.100.11:22",
            Devices::Iroh => "192.168.100.13:22",
        }
    }
}

#[derive(clap::ValueEnum, Clone, Debug, Default)]
enum Packages {
    #[default]
    Calypso,
    OdysseusDaemon,
    Nero,
    WheelButtons,
}

impl Packages {
    const fn get_name(&self) -> &'static str {
        match self {
            Packages::Calypso => "calypso",
            Packages::OdysseusDaemon => "odysseus-daemon",
            Packages::Nero => "nero2",
            Packages::WheelButtons => "wheel-buttons",
        }
    }

    fn get_bins(&self) -> Vec<&'static str> {
        match self {
            Packages::Calypso => vec!["calypso", "nerimd"],
            Packages::OdysseusDaemon => vec!["odysseus-daemon", "odysseus-uploader"],
            Packages::Nero => vec!["NEROApp"],
            Packages::WheelButtons => vec!["wheel_buttons"],
        }
    }

    const fn get_proc(&self) -> &'static str {
        match self {
            Packages::Calypso => "/etc/init.d/S76calypso",
            Packages::OdysseusDaemon => "/etc/init.d/S99odysseus-daemon",
            Packages::Nero => "/etc/init.d/S99nero2",
            Packages::WheelButtons => "/etc/init.d/S97wheel-buttons",
        }
    }
}

/// Deploy odysseus programs to odysseus devices
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct OdyDeployArgs {
    /// The device to deploy the binary to
    #[arg(short, long,value_enum, default_value_t = Devices::Tpu)]
    device: Devices,

    /// The package to update
    #[arg(short, long, value_enum)]
    pkg: Packages,

    /// The password of the device
    #[arg(short = 'w', long)]
    password: String,

    /// The password of the server
    #[arg(short = 's', long)]
    spwd: String,

    /// The commit SHA for the package
    #[arg(short, long)]
    id: String,

    /// If specified, will wait after the update step for the user to reconnect to the car network
    #[arg(short, long)]
    end: bool,
}

struct Client;

impl client::Handler for Client {
    type Error = russh::Error;

    async fn check_server_key(
        &mut self,
        _server_public_key: &PublicKey,
    ) -> Result<bool, Self::Error> {
        // Accept any key (NOT secure for production)
        Ok(true)
    }
}

struct Session {
    session: client::Handle<Client>,
    pub sftp: SftpSession,
}

impl Session {
    async fn connect<A: ToSocketAddrs>(
        addrs: A,
        uname: String,
        pwd: String,
    ) -> Result<Self, russh::Error> {
        let config = client::Config::default();

        let config = Arc::new(config);
        let sh = Client {};

        let mut session = client::connect(config, addrs, sh).await?;
        // use publickey authentication, with or without certificate

        session.authenticate_password(uname, pwd).await?;

        let channel = session.channel_open_session().await?;
        channel.request_subsystem(true, "sftp").await.unwrap();
        let sftp = SftpSession::new(channel.into_stream()).await.unwrap();

        Ok(Self { session, sftp })
    }

    async fn call(&mut self, command: &str) -> Result<u32, russh::Error> {
        let mut channel = self.session.channel_open_session().await?;
        channel.exec(true, command).await?;

        let mut code = None;
        let mut stdout = tokio::io::stdout();

        loop {
            // There's an event available on the session channel
            let Some(msg) = channel.wait().await else {
                break;
            };
            match msg {
                // Write data to the terminal
                ChannelMsg::Data { ref data } => {
                    stdout.write_all(data).await?;
                    stdout.flush().await?;
                }
                // The command has returned an exit code
                ChannelMsg::ExitStatus { exit_status } => {
                    code = Some(exit_status);
                    // cannot leave the loop immediately, there might still be more data to receive
                }
                _ => {}
            }
        }
        Ok(code.expect("program did not exit cleanly"))
    }

    // async fn close(&mut self) -> Result<(), russh::Error> {
    //     self.session
    //         .disconnect(Disconnect::ByApplication, "", "English")
    //         .await?;
    //     Ok(())
    // }
}

#[tokio::main]
async fn main() {
    let cli = OdyDeployArgs::parse();

    let defconfig_name = cli.device.get_defconfig();
    let pkg_name = cli.pkg.get_name();

    let mut ssh_server = match Session::connect(
        "server.finishlinebyner.com:59020".to_string(),
        "godzilla2".to_string(),
        cli.spwd,
    )
    .await
    {
        Ok(res) => res,
        Err(e) => {
            eprintln!("Error in connecting to server: {}", e);
            return;
        }
    };

    // step 1
    match match cli.pkg {
        Packages::Calypso => ssh_server
            .call(&format!(
                "sed -i \"1 s/.*/CALYPSO_VERSION = {}/\" ~/Projects/Odysseus/odysseus_tree/package/calypso/calypso.mk", cli.id
            ))
            .await,
        Packages::OdysseusDaemon => ssh_server
            .call(&format!(
                "sed -i \"1 s/.*/ODYSSEUS_DAEMON_VERSION = {}/\" ~/Projects/Odysseus/odysseus_tree/package/odysseus-daemon/odysseus-daemon.mk", cli.id
            ))
            .await,
        Packages::Nero => ssh_server.call(&format!("cd ~/Projects/Odysseus/odysseus_tree/sources/Nero-2.0/ && git pull && git checkout -f {}", cli.id)).await,
        Packages::WheelButtons => {
            eprintln!("UNSUPPORTED: SSH into the server and update the Odysseus repository to the new ref for wheel buttons!");
            Ok(0)
        },
    } {
        Ok(ret) => {
            if ret != 0 {
                eprintln!("Failure updating package version! {}", ret);
                return;
            }
        },
        Err(e) => {
            eprintln!("Error updating package version! {}", e);
            return;
        }
    }

    match ssh_server
        .call(&format!("docker compose -f ~/Projects/Odysseus/compose.yml run --entrypoint \"bash\"  --rm odysseus -ic \"make -C /home/odysseus/outputs/{} {}-reconfigure\"", defconfig_name, pkg_name))
        .await {
            Ok(ret) => {
                if ret != 0 {
                    eprintln!("Failure rebuilding package! {}", ret);
                    return;
                }
            },
            Err(e) => {
                eprintln!("Error rebuilding package! {}", e);
                return;
            }
        }

    let bins = cli.pkg.get_bins();

    let mut data: Vec<Vec<u8>> = vec![];
    for bin in bins.iter() {
        let bytes = match ssh_server
            .sftp
            .read(format!(
                "/home/godzilla2/Projects/Odysseus/outputs/{}/per-package/{}/target/usr/bin/{}",
                defconfig_name, pkg_name, bin
            ))
            .await
        {
            Ok(res) => res,
            Err(e) => {
                eprintln!("Error copying {} to local: {}", bin, e);
                return;
            }
        };
        data.push(bytes);
    }

    if cli.end {
        println!("WAITING, CONTINUE BY PRESSING ENTER WHEN CONNECTED TO HERMES");
        // Create a dummy string to hold the input
        let mut input = String::new();
        let _ = std::io::stdin().read_line(&mut input);
    }

    let mut ssh_ody =
        match Session::connect(cli.device.get_ipaddr(), "root".to_string(), cli.password).await {
            Ok(res) => res,
            Err(e) => {
                eprintln!("Error in connecting to odysseus device: {}", e);
                return;
            }
        };

    // stop running process to unlock the file
    match ssh_ody.call(&format!("{} stop", cli.pkg.get_proc())).await {
        Ok(ret) => {
            if ret != 0 {
                eprintln!("Failure stopping process! {}", ret);
                //return;
            }
        }
        Err(e) => {
            eprintln!("Error stopping process! {}", e);
            return;
        }
    }

    tokio::time::sleep(Duration::from_secs(1)).await;

    for (data, name) in data.iter().zip(bins.iter()) {
        if let Err(e) = ssh_ody.sftp.write(format!("/usr/bin/{}", name), data).await {
            eprintln!("Error writing file {} :{}", name, e);
        }
    }

    // start running process
    match ssh_ody.call(&format!("{} start", cli.pkg.get_proc())).await {
        Ok(ret) => {
            if ret != 0 {
                eprintln!("Failure starting process! {}", ret);
                return;
            }
        }
        Err(e) => {
            eprintln!("Error starting process! {}", e);
            return;
        }
    }
}
