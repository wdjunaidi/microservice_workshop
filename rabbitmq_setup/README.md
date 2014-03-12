Mac Server Setup

  Setup RabbitMQ via HomeBrew
    Activate via instructions
    Test by accessing rabbitmqctl
    Test by accessing Web manager: http://localhost:15672

  Setup an access client. I used Bunny gem for accessing via Ruby.

  Re-configure to allow non-localhost access
    Confirm via Web client that default exchange tied to 127.0.0.1
    In the .conf file, change 127.0.0.1 to 0.0.0.0
    Alternatively, an override can be specified in .bash_profile
    Stop and restart RabbitMQ. Confirm change via Web manager

  Enable the firewall (counter-intuitive, but necessary to open ports)
    System Preferences / Security & Privacy / Firewall
    Add rabbitmq-server to the list
    I got some prompts asking permission (maybe Erlang?). Grant permission.

  Use Network Utility to confirm ports are open now:
    5672 for RabbitMQ
    15672 for Web manager access

