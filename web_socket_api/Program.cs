using System.Net.WebSockets;
using web_socket_api.service;
using web_socket_api.service.implementation;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddScoped<Iweb_socket_service, websocket_service>();
builder.Services.AddSingleton<web_socket_connection_manager>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
/*
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
*/
var app = builder.Build();
/*
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
*/
app.UseWebSockets();
//app.UseHttpsRedirection();

//app.UseAuthorization();

app.MapControllers();

app.Run();
