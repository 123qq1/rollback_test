namespace web_socket_api.service
{
    public interface Iweb_socket_service
    {
        Task Connect(HttpContext context);
    }
}
