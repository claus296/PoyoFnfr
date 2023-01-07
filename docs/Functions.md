## Functions

#### (Replace "object" with things you want to change)
#### Also note that these settings are NOT available in base FNFR
## Image Functions
```lua
object:udraw()
```
Size up objects like this `object:udraw(3,3)`
Defaults to 7, 7 for pixel assets

```lua
object:cdraw(R,G,B,A)
```
> Alpha channel does not use 255 values

This is a function for automatically recolouring sprites. RGB Values are in 255 values
(This is used for the lights in week3)

```lua
object:cudraw(R,G,B,A)
```
> Alpha channel does not use 255 values

Same as `object:cdraw(R,G,B,A)` but also for upscaling assets

```lua
love.graphics.color.print("text",x,y,r,sx,sy,R,G,B,A,ox,oy,kx,ky)
```
> Alpha channel does not use 255 values

This is for automatically recolouring text. Works exactly like love.graphics.print(). RGBA values come after sx and sy (sizeX and sizeY)

```lua
love.graphics.color.printf("text",x,y,limit,align,r,sx,sy,R,G,B,A,ox,oy,kx,ky)
```
> Alpha channel does not use 255 values

This is for automatically recolouring text. Works exactly like love.graphics.printf(). RGBA values come after sx and sy (sizeX and sizeY)

```lua
love.graphics.setColorF(R,G,B,A)
```
> Alpha channel does not use 255 values

`love.graphics.setColor(R,G,B,A)` but uses 255 values

## Week Functions

```lua
weeks:drawHealthBar()
```
This is for drawing the healthbar in a week
