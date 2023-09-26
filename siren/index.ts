import typia from "typia";
import * as messageUtils from "./typia/generated/message.types";

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