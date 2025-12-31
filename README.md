# Wazuh (Makejail)

The main goal of this project is to implement, using [AppJail](https://github.com/DtxdF/AppJail) and [Director](https://github.com/DtxdF/director), what the Wazuh team does in [Docker](https://github.com/wazuh/wazuh-docker), to easily deploy Wazuh and all its components on FreeBSD.

Each Director file is tied to a configuration that makes sense on my system, but is likely wrong on yours. These Director files are just a PoC or a starting point for creating one that suits your environment. However, the Makejails and scripts are ready to use.

Take a look at each component to see the implementation notes and other related aspects:

- [X] [manager](manager/README.md)
- [X] [agent](agent/README.md)
- [X] [certs-generator](certs-generator/README.md)
- [X] [indexer](indexer/README.md)
- [X] [dashboard](dashboard/README.md)
