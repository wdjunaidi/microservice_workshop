using System;

using RabbitMQ.Client;

using RentalOffer.Core;

namespace RentalOffer.Need {

    public class Need {

        private readonly string busName;

        public static void Main(string[] args) {
            string host = args[0];
            string busName = args[1];

            Console.WriteLine(args);
            Console.WriteLine("Publishing the need...");
            new Connection(host, busName).WithOpen(new Need(busName).PublishNeed);
        }

        public Need(string busName) {
            this.busName = busName;
        }

        private void PublishNeed(Connection connection) {
            //var message = new NeedPacket().ToJson();
            var message = "punk";
            connection.Publish(message);
            Console.WriteLine(" [x] Published {0} on the {1} bus", message, busName);
        }

    }

}
