using System;
using System.Text;
using RabbitMQ.Client;

namespace RentalOffer.Core {

    public class Connection {

        private ConnectionFactory factory;
        private IModel channel;
        private string busName;

        public Connection(string host, string busName) {
            this.busName = busName;
            factory = new ConnectionFactory {
                    HostName = host,
                    UserName = busName,
                    Password = busName,
                    VirtualHost = busName
               };
        }

        public void WithOpen(Action<Connection> action) {
            using (var connection = factory.CreateConnection()) {
                using (channel = connection.CreateModel()) {
                    channel.QueueDeclare("", true, true, false, null);
                    channel.ExchangeDeclare("rapids", "fanout", true);
                    channel.QueueBind("", "rapids", "");

                    action(this);
                }
            }
        }

        public void Publish(string message) {
            var body = Encoding.UTF8.GetBytes(message);
            channel.BasicPublish("rapids", busName, null, body);
        }
    }
}
