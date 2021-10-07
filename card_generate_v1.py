import itertools
nbImg = 100
nbSymbol = 3
img = [i for i in range(nbImg)]
print(img)

card_list = list(i for i in itertools.combinations(img, nbSymbol))
print(len(card_list))
ok_card = []
while len(card_list):
    # num = 0
    num = 0
    ok_card.append(card_list[num])
    # print(len(j))
    card_list = list(set(card for card in card_list if len(
        set(card) & set(card_list[num])) == 1))

print('taille de la liste :', len(ok_card))
# print(ok_card)
# print(len(['abcde', 'afghi', 'ajklm', 'anopq', 'arstu', 'bfjnr', 'bgkpt', 'bhlou', 'bimqs', 'cfkqu',
#            'cgjos', 'chmpr', 'cilnt', 'dfmot', 'dglqr', 'dhkns', 'dijpu', 'eflps', 'egmnu', 'ehjqt', 'eikor']))
