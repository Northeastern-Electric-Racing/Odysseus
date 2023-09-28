import * as messageUtils from "./typia/generated/message.types";

// time messages must be within to be published, in miliseconds
const EXPIRATION_DURATION = 300000 // (5 minutes)

const server = Bun.serve<WebSocketData>({
    port: 3000,
    fetch(req, server) {
        server.upgrade(req, {
            data: {
                subTopics: new URL(req.url).searchParams.get("subTopics")
            },
        });

        return new Response("Upgrade to WebSocket failed :(", { status: 500 });
    },
    websocket: {
        open(ws) {

            if (ws.data.subTopics) {
                ws.subscribe(ws.data.subTopics); // TODO: parse for different topics and subscribe to them all
            }
        },
        message(ws, message) {

            // checks if valid JSON, if not log error and exit. 
            // Note: typia has quicker support for this but we need to check for two objects so this is non viable ATM
            let parsedMessage: any;
            try {
                parsedMessage = JSON.parse(message.toString());
            } catch (error) {
                console.log(error)
                console.log("This is the malformed message:", message.toString())
                return;
            }



            // checks if valid SubscriptionMessage, if not switch to publish block of code
            // then checks argument fields and subs/unsubs to arguments accordingly
            // NOTE: If you want to debug malformed messages or messages of different types, switch to assert typeguard
            if (messageUtils.strictCheckIsSubscriptionMessage(parsedMessage)) { // TODO: change to non-strict is typeguard for release
                const subscriptionMessage = parsedMessage as messageUtils.SubscriptionMessage;

                // iterate through the topics and either subscribe or unsubscribe
                for (const topic of subscriptionMessage.topics) {
                    if (subscriptionMessage.argument == "subscribe") {
                        ws.subscribe(topic);
                    } else {
                        ws.unsubscribe(topic)
                    }
                }
            } else if (messageUtils.strictCheckIsServerMessage(parsedMessage)) {
                const serverMessage = parsedMessage as messageUtils.ServerMessage;

                // check message time and ensure it is less than the expiration duration
                if ((Date.now() - serverMessage.unix_time) < EXPIRATION_DURATION) {
                    // overwrite message time with current time
                    // TODO: switch to more accurate GPS time once it becomes available
                    serverMessage.unix_time = Date.now();

                    // use typia stringify as it claims to be faster, note it *does not* typecheck before it does so
                    server.publish(serverMessage.node, messageUtils.stringifyServerMessage(serverMessage));
                } else {
                    console.log("Stale message:", message)
                }
            } else {
                console.log("Invalid Message:", message);
                // below indicates the first exact field that is incorrect when parsing of the type that had less erros
                // use when debugging invalid JSON structure
                // TODO: remove for production, expensive and verbose
                const subscriptionErrors = messageUtils.strictValidateSubscriptionMessage(parsedMessage).errors;
                const serverErrors = messageUtils.strictValidateServerMessage(parsedMessage).errors;
                if (subscriptionErrors.length < serverErrors.length) {
                    console.log("First subscription message error:", subscriptionErrors.at(0))
                } else {
                    console.log("First publish message error:", serverErrors.at(0))
                }
            }
        },
        close(ws) {

            if (ws.data.subTopics) {
                ws.unsubscribe(ws.data.subTopics); // TODO: parse for different topics and unsubscribe to them all
            }
        }
    }
});

console.log(`Listening on http://localhost:${server.port}`);