using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using System.Net.WebSockets;
using System.Text;

namespace web_socket_api.Controllers
{
    [Route("api/ws")]
    [ApiController]
    public class web_socket_controller : ControllerBase
    {
        List<Connection> connections = new List<Connection>();

        [HttpGet]
        public async Task Get() 
        {
            if (HttpContext.WebSockets.IsWebSocketRequest)
            {

                var cur_name = HttpContext.Request.Query["name"];

                using var web_socket = await HttpContext.WebSockets.AcceptWebSocketAsync();
                var con = new Connection(cur_name, web_socket);
                connections.Add(con);
                Broadcast(cur_name + " joined");
                await Receive(con);
            }
            else
            {
                HttpContext.Response.StatusCode = 400;
            }
        }

        private async Task Receive(Connection con)
        {
            var buffer = new byte[1024 * 4];

            while(con.socket.State == WebSocketState.Open)
            {
                var result = await con.socket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                Handle(result, buffer, con);
            }
        }

        private async Task Handle(WebSocketReceiveResult result, byte[] buffer,Connection con)
        {
            if (result.MessageType == WebSocketMessageType.Text)
            {
                string message = Encoding.UTF8.GetString(buffer);
                await Broadcast(con.cur_name + " : " + message);

            }
            else if (result.MessageType == WebSocketMessageType.Close || con.socket.State == WebSocketState.Aborted)
            {
                await con.socket.CloseAsync(result.CloseStatus.Value, result.CloseStatusDescription, CancellationToken.None);
            }
        }

        private async Task Broadcast(string message)
        {
            var bytes = Encoding.UTF8.GetBytes(message);
            foreach (var connection in connections)
            {
                if(connection.socket.State == WebSocketState.Open)
                {
                    var array_segment = new ArraySegment<byte>(bytes, 0, bytes.Length);
                    await connection.socket.SendAsync(array_segment,WebSocketMessageType.Text,true,CancellationToken.None);
                }
            }
        }

        private struct Connection
        {
            public Connection(string _cur_name, WebSocket _web_socket)
            {
                cur_name = _cur_name;
                socket = _web_socket;
            }

            public string cur_name;
            public WebSocket socket;
        }
    }
}
