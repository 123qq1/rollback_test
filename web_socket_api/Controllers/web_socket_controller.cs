using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using System.Net.WebSockets;
using System.Text;
using web_socket_api.service;

namespace web_socket_api.Controllers
{
    [Route("api/ws")]
    [ApiController]
    public class web_socket_controller : ControllerBase
    {

        public web_socket_controller(Iweb_socket_service websocket_service)
        {
            _web_socket_service = websocket_service;
        }

        private Iweb_socket_service _web_socket_service;

        [HttpGet]
        public async Task Get() 
        {
            if (HttpContext.WebSockets.IsWebSocketRequest)
            {

                await _web_socket_service.Connect(HttpContext);
            }
            else
            {
                HttpContext.Response.StatusCode = 400;
            }
        }

    }
}
