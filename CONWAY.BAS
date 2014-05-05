DECLARE SUB detectEmpty ()
DECLARE SUB seedGame ()
DECLARE SUB drawPoint (x AS INTEGER, y AS INTEGER, col AS INTEGER)
DECLARE SUB evolveGame ()
DECLARE SUB drawGame ()

'Globals
gamewidth = 20
gameheight = 20
defaultcolor = 15  'white
scale = 4  'n-times zoom

'game array is an adjacency list of sorts:
'game(line, idx) = column
'if game(15, idx) = 0, no other active tiles in this line.
DIM game(gamewidth, gameheight) AS INTEGER


'Off we go!
SCREEN 13
seedGame
drawGame
WHILE INKEY$ = ""
    evolveGame
    detectEmpty
WEND

SUB detectEmpty
'detect if game is empty. Reseed if so.
SHARED gameheight
SHARED game() AS INTEGER

FOR y = 1 TO gameheight
    'If there's an active cell, we're done here.
    IF game(y, 1) <> 0 THEN EXIT SUB
NEXT y

'No live cells, apparently. So reseed.
seedGame

END SUB

SUB drawGame
'Draw game, from scratch.
SHARED gamewidth, gameheight, defaultcolor
SHARED game() AS INTEGER

FOR y = 1 TO gameheight
    FOR i = 1 TO gamewidth
        'skip if we are done with this line.
        x = game(y, i)
        IF x = 0 THEN GOTO drawContY

        drawPoint INT(x), INT(y), INT(defaultcolor)
    NEXT i

drawContY:
NEXT y
END SUB

SUB drawPoint (x AS INTEGER, y AS INTEGER, col AS INTEGER)
SHARED scale

FOR xs = 0 TO scale - 1
    FOR ys = 0 TO scale - 1
        PSET ((x - 1) * scale + xs, (y - 1) * scale + ys), col
    NEXT ys
NEXT xs

END SUB

SUB evolveGame
SHARED gamewidth, gameheight
SHARED game() AS INTEGER
SHARED defaultcolor

DIM neighbors(gamewidth, gameheight) AS INTEGER

'Calculate neighbors.
FOR y = 1 TO gameheight
    FOR i = 1 TO gamewidth
        x = game(y, i)
        'Skip if we're done with this line.
        IF x = 0 THEN GOTO evolveContY

        FOR nx = x - 1 TO x + 1
            FOR ny = y - 1 TO y + 1
                IF nx <> 0 AND ny <> 0 AND nx <> gamewidth + 1 AND ny <> gamewidth + 1 THEN
                    IF nx = x AND ny = y THEN
                        'Mark as active cell.
                        neighbors(x, y) = neighbors(x, y) + 10
                    ELSE
                        'Count neighbors.
                        neighbors(nx, ny) = neighbors(nx, ny) + 1
                    END IF
                END IF
            NEXT ny
        NEXT nx
    NEXT i

evolveContY:
NEXT y


'Determine live cells for next step based on neighbors.
FOR y = 1 TO gameheight
    idx = 1  'build adjacency list.

    FOR x = 1 TO gamewidth
        'Previously dead with 3 neighbors, or:
        'prev. live with 2 or 3 neighbors.
        IF neighbors(x, y) = 3 OR neighbors(x, y) = 12 OR neighbors(x, y) = 13 THEN
            game(y, idx) = x
            idx = idx + 1
           
            'Draw the cell.
            drawPoint INT(x), INT(y), INT(defaultcolor)
        ELSEIF neighbors(x, y) >= 10 THEN
            'Blank out previously active cell.
            drawPoint INT(x), INT(y), 0  'black
        END IF

        neighbors(x, y) = 0
    NEXT x

    'Mark end of adjacency list.
    IF idx <= gamewidth THEN
        game(y, idx) = 0
    END IF
NEXT y

END SUB

SUB seedGame
'Add some randomized live cells.
SHARED gamewidth, gameheight
SHARED game() AS INTEGER

RANDOMIZE TIMER

'Fill up to 20% of the board.
livecells = INT(RND * gamewidth * gameheight / 5) + 1

'Remember our position in the game array
DIM gameidx(gameheight) AS INTEGER

FOR i = 1 TO livecells
    DO
        position = INT(RND * gamewidth * gameheight) + 1
        y = position MOD gamewidth
    LOOP UNTIL gameidx(y) + 1 < gamewidth  'Don't overfill a line.
    x = INT(position / gamewidth)

    game(y, gameidx(y) + 1) = x

    'Move to the next spot in this line.
    gameidx(y) = gameidx(y) + 1
NEXT i

END SUB

