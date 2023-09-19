import * as messagetypes from "./Odyssey-Base/src/types/message.types";
import * as topics from "./Odyssey-Base/src/types/topic";

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

            labelOperationLoop: if (subscriptionMessage.argument && subscriptionMessage.topics) {

                // check the argument field for the correct operation, or break out of if block with an error logged
                let isSubscribe: boolean;
                if (subscriptionMessage.argument == "subscribe") {
                    isSubscribe = true;
                } else if (subscriptionMessage.argument == "unsubscribe") {
                    isSubscribe = false;
                } else {
                    console.log("Invalid argument present:", message.toString())
                    break labelOperationLoop;
                }

                for (const topic of subscriptionMessage.topics) {
                    if ((<any>Object).values(topics.Topic).includes(topic)) {
                        if (isSubscribe) {
                            ws.subscribe(topic);
                        } else {
                            ws.unsubscribe(topic)
                        }
                    } else {
                        console.log("Invalid topic present:", topic.toString());
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