# CS 4730 - Team Game Final Submission	

## Members

- Andrew Balch (xxv2zh)
- Elliott Druga (jhe6rv)
- Varun Varma (kgy6hy)
- Zihan Mei (zm4hy)

## Game Title

Hoki Poki Potion Place

## GitHub Repo Link

https://github.com/uva-cs4730-s25/team-game-hokey-pokey-potion-place 

## Brief Elevator Pitch Describing Game

You own a drive-through potion shop and must fulfil customer orders by combining strange ingredients in a cauldron. However, ingredients have strange and wacky behaviors, different densities that cause them to rise to the top or sink to the bottom, and some ingredients even have catastrophic interactions that you must be careful to avoid or risk ruining your potion. Make a profit and pay off your 2000 gold loan by quickly and accurately serving your customers.

## Game Instructions

The game is controlled largely through pointing and clicking with the cursor, so an external mouse rather than a touchpad is recommended but not required. There is an included tutorial with an interactive explanation of the game’s basic mechanics/dynamics, but as a primer, vials containing potion ingredients can be held by clicking on them. With the vial in hand, clicking-and-holding over an empty space in the cauldron will pour out the contents of the vial, and clicking-and-holding over a potion in the cauldron (indicated by text in the bottom-left corner stating the name of the potion) will collect the potion into the vial. Clicking on the customer with a vial in hand will serve them the contents of the vial, and a payment will be calculated based on the purity of the potion within the vial and whether the time limit was exceeded or not. New ingredients can be purchased in the shop, and discovered recipes are listed in the recipe book (both in the upper-right). You begin the game with 100 gold, and win the game if you make 2000 gold. If you repeatedly serve bad potions to your customers, your reputation will decrease and your shop will go out of business. Similarly, if you run out of gold at any point, you go bankrupt and lose.

## Available Content

We designed 15 different ingredients that combine to produce >10 possible potions and reactions! These potions have varying levels of difficulty to make, and some of them have very interesting properties that could help you or cause you trouble. Basically, there’s only one mission – collect 2000 gold, but it’s also fun to ignore all orders and just try and make more kinds of potions! As you successfully fulfill orders, the game difficulty increases by decreasing the time limit and allowing customers to order more complex potions. All potion orders are possible only after customers are served successfully 9 times, but they can be discovered at any point!

Below are a few tips for playing (Don’t look at this if you just want to enjoy the game!):

1. Clear a vial, look at existing reactions, and buy new ingredients at the top-right corner!
2. Potions have varying density, so the order you add the ingredients is important!
3. Fenwick Tree can be made by Dragon’s blood and Fairy Dust, and can be dissolved by water. It GROWS!
4. Dreamroot Spore is made of Fenwick Tree and Caustic Dreams (Sweat of Newt + Fairy Dust). It floats around and is hard to get rid of!
5. Flipping the cauldrons is helpful, not only for clearing the potions inside.
6. Some reactions are explosive! Be careful not to mix Water and Fairy Dust…

## Lessons Learned

We learned that games are much harder than other pieces of software to keep loosely-coupled. With several people working on different parts of the game, it was easy to make a change that impacted another part of the code.

We also learned that good ideas require careful planning to become something really fun. We had this “potion + reaction” idea at a very early stage, but it took us a lot of time and effort to refine the details, carefully consider the reactions, and combine it to other mechanics to make it actually interesting to play.

Besides, playtesting is crucial in game design. The feedback from our classmates inspired us a lot and made us reconsider how to provide players a smooth and fun experience. By solving the problems raised one by one, our game makes more and more sense. Our game became a lot more playable the day after playtesting.
