package com.microservices.rentaloffer;

import com.rabbitmq.client.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Map;
import java.util.HashMap;

public class Monitor {
    protected static Logger logger = LoggerFactory.getLogger(Monitor.class);
    protected Channel channel;
    protected QueueingConsumer consumer;
    protected final String amqpUrl;
    protected final String queue = "";
    protected final String exchange = "rapids";
    protected final String exchangeType = "fanout";
    protected final String routingKey;

    public static void main(String[] args) {
        String host = args[0];
        String busName = args[1];
        String url = String.format("amqp://%s:%s@%s/%s", busName, busName, host, busName);
        logger.info("Getting it going...");
        Monitor monitor = new Monitor(url);
        monitor.deliveryLoop();
    }

    public Monitor(String amqpUrl) {
        this.amqpUrl = amqpUrl;
        this.channel = channel(factory());
        this.routingKey = queue;  // Assumes queue and routingKey are the same.
        declareExchange();
        this.consumer = consumer(channel, queue(channel));
        bindQueueToExchange(channel);
    }

    public void deliveryLoop() {
        logger.info(String.format(" [*] Waiting for solutions on the %s bus... To exit press CTRL+C", amqpUrl));
        while (true) {
            final QueueingConsumer.Delivery delivery = delivery(consumer);
            if (delivery != null) {
                try {
                    logger.info(String.format("Message Received: %s", message(delivery)));
                    ack(channel, delivery);
                } catch (Exception ex) {
                    nack(channel, delivery);
                }
            }
        }
    }

    protected Map<String, Object> headers(QueueingConsumer.Delivery delivery) {
        AMQP.BasicProperties properties = delivery.getProperties();
        return properties.getHeaders();
    }

    protected String message(QueueingConsumer.Delivery delivery) {
        try {
            return new String(delivery.getBody(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException("Failed to parse message:", e);
        }
    }

    protected void nack(Channel channel, QueueingConsumer.Delivery delivery) {
        try {
            long deliveryTag = delivery.getEnvelope().getDeliveryTag();
            channel.basicNack(deliveryTag, false, false);
            logger.warn(String.format("Rejected message: tag: %d body: %s ", deliveryTag, new String(delivery.getBody())));
        } catch (IOException e) {
            throw new RuntimeException("Failed to nack delivery:", e);
        }
    }

    protected void ack(Channel channel, QueueingConsumer.Delivery delivery) {
        try {
            channel.basicAck(delivery.getEnvelope().getDeliveryTag(), false);
        } catch (IOException e) {
            throw new RuntimeException("Failed to ack delivery:", e);
        }
    }

    protected QueueingConsumer.Delivery delivery(QueueingConsumer consumer) {
        try {
            return consumer.nextDelivery();
        } catch (InterruptedException e) {
            throw new RuntimeException("Consumer interrupted:", e);
        }
    }

    protected QueueingConsumer consumer(Channel channel, String queueName) {
        try {
            QueueingConsumer consumer = new QueueingConsumer(channel);
            channel.basicConsume(queueName, false, consumer);
            return consumer;
        } catch (IOException e) {
            throw new RuntimeException("Could not create consumer:", e);
        }
    }

    protected void bindQueueToExchange(Channel channel) {
        try {
            channel.queueBind(queue, exchange, routingKey);
        } catch (IOException e) {
            throw new RuntimeException("Could not bind queue to exchange:", e);
        }
    }

    protected String queue(Channel channel) {
        try {
            channel.queueDeclare(queue, true, false, false, new HashMap<String, Object>());
            return queue;
        } catch (IOException e) {
            throw new RuntimeException("Could not declare queue:", e);
        }
    }

    protected void declareExchange() {
        try {
            channel.exchangeDeclare(exchange, exchangeType, true);
        } catch (Exception e) {
            throw new RuntimeException("Could not declare exchange:", e);
        }
    }

    protected Channel channel(ConnectionFactory factory) {
        try {
            Connection connection = factory.newConnection();
            return connection.createChannel();
        } catch (IOException e) {
            throw new RuntimeException("Could not create channel:", e);
        }
    }

    protected ConnectionFactory factory() {
        try {
            ConnectionFactory factory = new ConnectionFactory();
            factory.setUri(amqpUrl);
            logger.info(amqpUrl);
            return factory;
        } catch (Exception ex) {
            String message = String.format("Failed to initialize ConnectionFactory with %s.", amqpUrl);
            throw new RuntimeException(message, ex);
        }
    }

    void setLogger(Logger testLogger) {
        // only use for testing
        this.logger = testLogger;
    }
}
