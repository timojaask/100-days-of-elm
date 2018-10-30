## Day 50

Today I finished writing the Cypress integration tests that I started writing yesterday. This gives me the necessary confidence to refactor the app code and know it still works without having to test each special case manually.

The cool thing is that writing the tests made me discover a bug in my "New game" button functionality.

So now I've refactored the code a bit, DRYing it up a bit, becase a lot of code was just blunt repetition with small changes depending on the direction of the move. So now instead of having four functions for each direction, there's one function that takes the direction as a parameter, reducing a lot of repetition.

Now is probably a good time to add detection of when the game is won or lost.

Game won is easy -- if after moving any value is 2048 -- game is won. Lost state can be checked by trying to move in each direction and seeing if the board changes at any point -- if not, the game is over. Otherwise game is still on.

Also, only generate new cell if game is still on, otherwise do nothing.

To test winning, I could use the following starting board, and then press Left:

```
http://localhost:8080/?board=1024_0_1024_0_0_0_0_0_0_0_0_0_0_0_0_0
```

Or loading this board, which already contains "2048":

```
http://localhost:8080/?board=2048_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
```

To test losing, I could use the following starting board and then press Left:

```
http://localhost:8080/?board=2_4_8_16_4_8_16_32_8_16_32_64_0_32_64_128
```

Or loading this board, where there are no possible moves left:

```
http://localhost:8080/?board=2_4_8_16_4_8_16_32_8_16_32_64_16_32_64_128
```