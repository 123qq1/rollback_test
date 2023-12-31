﻿using System.Net.WebSockets;
using System.Runtime.InteropServices;
using System.Text;

namespace web_socket_api.service.implementation
{

    public class websocket_service : Iweb_socket_service
    {
        private web_socket_connection_manager _connectionManager;
        private string con_name;
        private Guid con_id;
        private int lag = 300;

        public websocket_service(web_socket_connection_manager connectionManager)
        {
            _connectionManager = connectionManager;
        }

        public async Task Connect(HttpContext context)
        {

            var cur_name = context.Request.Query["name"];

            using var web_socket = await context.WebSockets.AcceptWebSocketAsync();
            con_name = cur_name;
            con_id = _connectionManager.AddSocket(web_socket);
            await send(
                "|{" +
                "\"name\":\""+con_name+"\"," +
                "\"type\":\"id\"," +
                "\"id\":\"" + con_id+"\""+
                "}|"
                ,web_socket);
            await Receive(web_socket);
        }

        private async Task Receive(WebSocket con)
        {
            var buffer = new byte[1024 * 4];

            while (con.State == WebSocketState.Open)
            {
                buffer = new byte[1024 * 4];
                var result = await con.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                Handle(result, buffer, con);
            }
        }

        private async Task Handle(WebSocketReceiveResult result, byte[] buffer, WebSocket con)
        {
            await Task.Delay(lag);
            if (result.MessageType == WebSocketMessageType.Text)
            {
                string message = Encoding.UTF8.GetString(buffer);
                await Broadcast(message);
            }
            else if (result.MessageType == WebSocketMessageType.Close || con.State == WebSocketState.Aborted)
            {
                await Console.Out.WriteLineAsync("Closing " + con_name);
                await con.CloseAsync(result.CloseStatus.Value, result.CloseStatusDescription, CancellationToken.None);
                _connectionManager.RemoveSocket(con_id);
            }
        }

        private async Task Broadcast(string message)
        {
            var bytes = Encoding.UTF8.GetBytes(message);
            foreach (var connection in _connectionManager.GetAllSockets())
            {
                if (connection.State == WebSocketState.Open)
                {
                    var array_segment = new ArraySegment<byte>(bytes, 0, bytes.Length);
                    connection.SendAsync(array_segment, WebSocketMessageType.Text, true, CancellationToken.None);
                }
            }
        }

        private async Task send(string message, WebSocket soc)
        {
            var bytes = Encoding.UTF8.GetBytes(message);

            var array_segment = new ArraySegment<byte>(bytes, 0, bytes.Length);
            soc.SendAsync(array_segment, WebSocketMessageType.Text, true, CancellationToken.None);

        }
    }
}
