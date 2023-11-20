using System.Net.WebSockets;

namespace web_socket_api.service
{
    public class web_socket_connection
    {
        public web_socket_connection(string _cur_name, WebSocket _web_socket)
        {
            cur_name = _cur_name;
            socket = _web_socket;
        }

        public string cur_name;
        public WebSocket socket;
    }
}
