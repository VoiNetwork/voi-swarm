# Troubleshooting

## Startup State for Services in Stack

```bash
docker stack ps --no-trunc voinetwork`
```

## Replication State for Services in a Stack

```bash
docker service ls
```

## Pull Log Files for a Service

```bash
docker service logs voinetwork_algod
```

## Inspect Service

```bash
docker inspect voinetwork_algod
```

## Testing Notifications

To test notifications, execute the following command:

```bash
~/voi/bin/notification-test
```
