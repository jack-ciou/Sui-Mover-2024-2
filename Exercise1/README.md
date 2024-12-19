# Beginnger Village

### Pacakge ID

```
0x2ee85ec61775745b66bdc11039077c842db95a8cc736313a22fee6e5dc1798c1
```

### Hint

CLI commands

1. Switch to KapyCrew owner account

```
sui client switch --address [Owner Account] --env mainnet
```

2. Check the data of your KapyCrew (like `index` etc)

```
sui client object [KapyCrew Object ID]
```

3. Call the `solve` function to recruit first pirate

```
sui client call --package [Package ID] --module [Module Name] --function [Function Name] --args [KapyWorld Object ID] [KapyCrew Object ID] [Crew Name] [Answer 1] [Answer 2]
```
