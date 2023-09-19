import * as messagetypes from "./Odyssey-Base/src/types/message.types";

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

            // checks if valid JSON, if not log error and exit
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
            const subscriptionMessage = parsedMessage as messagetypes.SubscriptionMessage;

            if (subscriptionMessage.argument && subscriptionMessage.topics) {
                if (subscriptionMessage.argument == "subscribe") {
                    for (const topic of subscriptionMessage.topics) {
                        ws.subscribe(topic);
                    }
                } else if (subscriptionMessage.argument == "unsubscribe") {
                    for (const topic of subscriptionMessage.topics) {
                        ws.unsubscribe(topic);
                    }
                }
                return;
            } else {

                // TODO: handle JSON for ServerData checking and publishing in correct topic
                server.publish("test", message);
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