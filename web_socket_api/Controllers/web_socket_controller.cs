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
        List<WebSocket> connections = new List<WebSocket>();

        [HttpGet]
        public async Task Get() 
        {
            if (HttpContext.WebSockets.IsWebSocketRequest)
            {
                using var web_socket = await HttpContext.WebSockets.AcceptWebSocketAsync();
                connections.Add(web_socket);
                await Recive(web_socket);
            }
            else
            {
                HttpContext.Response.StatusCode = 400;
            }
        }

        private async Task Recive(WebSocket web_socket)
        {
            var buffer = new byte[1024 * 4];

            while(web_socket.State == WebSocketState.Open)
            {
                var result = await web_socket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                Handle(result, buffer, web_socket);
            }
        }

        private async Task Handle(WebSocketReceiveResult result, byte[] buffer,WebSocket web_socket)
        {
            if (result.MessageType == WebSocketMessageType.Text)
            {
                string message = Encoding.UTF8.GetString(buffer);
                await Broadcast(message);

            }
            else if (result.MessageType == WebSocketMessageType.Close || web_socket.State == WebSocketState.Aborted)
            {
                await web_socket.CloseAsync(result.CloseStatus.Value, result.CloseStatusDescription, CancellationToken.None);
            }
        }

        private async Task Broadcast(string message)
        {
            var bytes = Encoding.UTF8.GetBytes(message);
            foreach (var socket in connections)
            {
                if(socket.State == WebSocketState.Open)
                {
                    var array_segment = new ArraySegment<byte>(bytes, 0, bytes.Length);
                    await socket.SendAsync(array_segment,WebSocketMessageType.Text,true,CancellationToken.None);
                }
            }
        }
    }
}
