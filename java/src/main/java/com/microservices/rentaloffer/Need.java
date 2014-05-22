package com.microservices.rentaloffer;

import com.rabbitmq.client.*;

import java.io.IOException;

public class Need {

    protected final ConnectionFactory factory = new ConnectionFactory();
    protected Channel channel;
    protected Connection connection;
    protected AMQP.BasicProperties basicProperties;
    protected String exchange = "rapids";
    protected String queue = "";

    public static void main(String[] args) {
        String host = args[0];
        String busName = args[1];
        String url = String.format("amqp://%s:%s@%s/%s", busName, busName, host, busName);
        Need need = new Need(url);
        need.publish(new NeedPacket().toJson());
        need.close();
    }

    public Need(String uriString) {
        try {
            factory.setUri(uriString);
            connection = factory.newConnection();
            channel = connection.createChannel();
            basicProperties = new AMQP.BasicProperties().builder().build();
            this.exchange = exchange;
            this.queue = queue;
        } catch (Exception e) {
            throw new RuntimeException("Could not create publisher:", e);
        }
    }

    public void publish(String message) {
        try {
            // Assume that queue and routingKey are the same, as in other parts of Pika
            channel.basicPublish(exchange, queue, basicProperties, message.getBytes());
        } catch (Exception e) {
            throw new RuntimeException("Could not publish message:", e);
        }
    }

    public void close() {
        try {
            channel.close();
            connection.close();
        } catch (Exception e) {
            throw new RuntimeException("Could not close connection:", e);
        }
    }
}
