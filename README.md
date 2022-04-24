# Magic Status

A [KDE Plasma](https://kde.org/plasma-desktop/) [Widget](https://store.kde.org/browse/) to display custom status messages on [Panels](https://userbase.kde.org/Plasma/Panels).

<div align="center">
  <img alt="A screenshot of a panel with two widgets, the current time and the current song playing." src="https://raw.githubusercontent.com/gbaptista/assets/main/magic-status/magic-status-panel.png" width="40%">
</div>

- [Installing](#installing)
- [Configuring](#configuring)
- [Development](#development)

## Installing

```sh
git clone https://github.com/gbaptista/magic-status.git \
  /usr/share/plasma/plasmoids/com.github.gbaptista.magic-status
```

Right-click on a panel, _"Add Widgets..."_ and search for _"Magic Status"_.

I don't remember, but you may need to restart _Plasma Shell_ by rebooting the computer, logoff/login, or the following command:

```shell
plasmashell --replace
```

## Configuring

The core idea of _Magic Status_ is to be easily connectable to a data source. So, you just need to provide an endpoint that responds to a `GET` request rendering the following expected JSON:

```json
{
  "messages": [
    "11:40:20",
    "11:40"
  ]
}
```

In the above example, the widget will display the current time. We are providing two possible messages, and to switch between them, you can click on the currently displayed message.

You can configure it by right-clicking and _"Configure Magic Status..."_:

<div align="center">
  <img alt="A screenshot of the configuration screen." src="https://raw.githubusercontent.com/gbaptista/assets/main/magic-status/magic-status-config.png" width="60%">
</div>

As you can display any message that you want, anything is possible. I have two endpoints on my local API, http://localhost:5000/time and http://localhost:5000/music.

The `/music` displays the current song playing:
```
{
  "messages": [
    "Rival Sons - Do Your Worst"
  ]
}
```
So, with two instances of the widget in my panel, I have the following result:

<div align="center">
  <img alt="A screenshot of a panel with two widgets, the current time and the current song playing." src="https://raw.githubusercontent.com/gbaptista/assets/main/magic-status/magic-status-panel.png" width="40%">
</div>

## Development

```sh
cd /usr/share/plasma/plasmoids/com.github.gbaptista.magic-status
plasmoidviewer -a .

plasmashell --replace
```
