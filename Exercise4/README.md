# Beginnger Village

### Pacakge ID
```
0xe283a855d889480c1e7ac1be37415a6fe4bcbfd79d1d648d45119bddd19da8e9
```
### Dougeon Object ID
```
0x94eca7c3b73e0679ca14ba0626d8f045c1d53e9448bd5f31be64d138a7f8bf93
```
### Hint
CLI commands
1. Switch to KapyCrew owner account
```
sui client switch --address [Owner Account] --env mainnet
```
2. Move your character * N steps
```
sui client call --package [Package ID] --module [Module Name] --function [Function Name] --args [Dougeon Object ID] [Direction 1] [Direction 2] [Step]
```
3. Call the `goal` function to open the treasure box and recruit your pirate
```
sui client call --package [Package ID] --module [Module Name] --function [Function Name] --args [Dougeon Object ID] [KapyWorld Object ID] [KapyCrew Object ID]
```