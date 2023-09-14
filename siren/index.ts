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

            // TODO: allow subscriptions to additional topics and unsubscribing from topics

            server.publish("test", message);
            // TODO: allow selection of publishing channel
        },
        close(ws) {
            
            if (ws.data.subTopics) {
                ws.unsubscribe(ws.data.subTopics); // TODO: parse for different topics and unsubscribe to them all
            }
        }
    }
});

console.log(`Listening on http://localhost:${server.port}`);