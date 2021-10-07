'''
Script used to generate the cards content of the game "Dobble" : https://fr.asmodee.com/fr/games/dobble/

This may be useful to create a custom set of card, with a different number of symbols by cards, or custom set of symbols.

N.B: The number of card, and the total number of symbols, is the same, and it only depends on the number of symbols on each card, due to the constrait that each pair of cards in the game shall have exactly one symbol in common.
'''
from random import shuffle


class CardsGenerator(object):

    def __init__(self, nbSymByCard):
        """
            Create a cards generator for Dobble game.

            The method used to generate the cards doesn't work for any number of symbols per card.
            Neverthess, it still work for the number of symbols on original Dobble games : 8 and 6 symbols, and further test have shown that this algorithm works for these numbers of symbols per card : [2,3,4,6,8,12,14,18,20,24,30,38,42,44,48]

            :param nbSymByCard: Number of symbols on each card of the game
            :type nbSymByCard: integer greater than 1
        """
        self.nbSymByCard = 0
        if nbSymByCard > 1:
            self.nbSymByCard = nbSymByCard  # Number of symbols on each cards
            # Number of cards is the same as the total number of symbols used
            self.nbCards = (self.nbSymByCard**2) - self.nbSymByCard + 1
        else:
            print(
                "%d is not a valid number of symbols by card, please enter a integer greater than 1")

    def generate(self, mixUpCardsContent=False):
        """
            Generate and return the content of the cards

            Return value is a list of lists
            Each symbol on a card is a number, from 1 to the total number of symbols
            The total number of symbols is equal to the total number of cards
            The total number of cards is equal to : (n*n)-n+1 with n the number of symbols on each card
            Therefore, the return value is a list of (n*n)-n+1 lists of n elements

            :param mixUpCardsContent: Mix up the order of the symbols within each card, set to Trus to mix up (default=False)
            :type mixUpCardsContent: Boolean
            :return: A list of lists representing the cards content.
            :rtype: List of lists
        """
        cards = []
        if self.nbSymByCard > 0:
            n = self.nbSymByCard - 1
            t = []
            t.append([[(i+1)+(j*n) for i in range(n)] for j in range(n)])
            for ti in range(n-1):
                t.append([[t[0][((ti+1)*i) % n][(j+i) % n]
                           for i in range(n)] for j in range(n)])
            t.append([[t[0][i][j] for i in range(n)] for j in range(n)])
            for i in range(n):
                t[0][i].append(self.nbCards - n)
                t[n][i].append(self.nbCards - n + 1)
                for ti in range(n-1):
                    t[ti+1][i].append(self.nbCards - n + 1 + ti + 1)
            t.append([[(i+(self.nbCards-n)) for i in range(self.nbSymByCard)]])
            for ti in t:
                cards = cards + ti
            if mixUpCardsContent:
                for line in cards:
                    shuffle(line)
        return cards

    def check(self, cards, verbose=False):
        """
            Check if the content of a Dobble game respect its requirement

            Check if the given cards content respect the rule of the Dobble game, i.e. the number of symbols in common on any pair of cards is exactly one

            :param cards: Content of all the cards of the game
            :type cards: List of lists
            :param verbose: Print all the errors on standard output, or only if there is errors or not (set to True to print all errors), default value is False
            :type verbose: Boolean
            :return: The number of errors detected in the cards of the game
            :rtype: integer
        """
        nbErr = 0
        for i in range(self.nbCards):
            chklst = [n for n in range(self.nbCards)]
            chklst.remove(i)
            for j in chklst:
                nbSymbolsInCommon = [(k in cards[j] and k != 0)
                                     for k in cards[i]].count(True)
                if nbSymbolsInCommon != 1:
                    nbErr = nbErr + 1
                    if verbose == True:
                        print(
                            "Error detected, %d symbols are matching on these 2 cards:" % nbSymbolsInCommon)
                        print(cards[i])
                        print(cards[j])
        return nbErr

    def display(self, cards):
        """
            Print on standard output the content of the Dobble game cards

            :param cards: Content of all the cards of the game
            :type cards: List of lists
        """
        print("All %d cards content with %d symbols on each:" %
              (len(cards), len(cards[0])))
        for card in cards:
            print(card)


# Main code, using the CardsGenerator class
nbSymByCard = int(input(
    "Enter the number of symbols on each card of the Dobble game to generate:"))
test = CardsGenerator(nbSymByCard)
game = test.generate()
# game[0][7]=12      #introduce an error to validate the check() function
test.display(game)
nbErr = test.check(game, verbose=False)
if nbErr != 0:
    print("%d pairs of cards don't respect the Dobble game requirements" % nbErr)
else:
    print("No errors detected in cards")
