using System.Net.WebSockets;
using System.Text;

Console.WriteLine("Hello, World!");

var web_socket = new ClientWebSocket();

Random ran = new Random();

string name = ran.Next(10).ToString();
Thread.Sleep(5000);
Console.WriteLine("Connecting");
await web_socket.ConnectAsync(new Uri($"ws://web_socket_api/api/ws?name={name}"), CancellationToken.None);
Console.WriteLine("Connected!");

var receive_task = Task.Run(async () =>
{
    var buffer = new byte[1024 * 4];
    while (true)
    {
        var result = await web_socket.ReceiveAsync(new ArraySegment<byte>(buffer),CancellationToken.None);

        if(result.MessageType == WebSocketMessageType.Close)
        {
            break;
        }

        var message = Encoding.UTF8.GetString(buffer, 0, result.Count);
        Console.WriteLine(message);
    }
});

var send_task = Task.Run(async () =>
{
    while(true)
    {
        var message = Console.ReadLine();
        if(message == "exit")
        {
            break;
        }
        var bytes = Encoding.UTF8.GetBytes(message);
        await web_socket.SendAsync(new ArraySegment<byte>(bytes),WebSocketMessageType.Text,true, CancellationToken.None);
    }
});

await Task.WhenAny(send_task,receive_task);

if(web_socket.State != WebSocketState.Closed)
{
    await web_socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closing", CancellationToken.None);
}

await Task.WhenAll(send_task,receive_task);