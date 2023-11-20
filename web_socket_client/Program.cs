using System.Net.WebSockets;
using System.Text;


var web_socket = new ClientWebSocket();

Random ran = new Random();
int num = ran.Next(10);
string name = num.ToString();
Console.WriteLine("Hello, World! I am " + name);

Thread.Sleep(5000 + num * 1000);
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
            await Console.Out.WriteLineAsync("Closing");
            break;
        }

        var message = Encoding.UTF8.GetString(buffer, 0, result.Count);
        Console.WriteLine(message + web_socket.State.ToString());
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
    Console.WriteLine(web_socket.State.ToString());
    await web_socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closing", CancellationToken.None);
}

await Task.WhenAll(send_task,receive_task);