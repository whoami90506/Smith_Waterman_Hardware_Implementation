from argparse import ArgumentParser

parser = ArgumentParser(description='A program that convert the data to hardware format.')
parser.add_argument('t', help='file that store sequence T.')
parser.add_argument('s', help='file that store sequence S and parameter.')
parser.add_argument('o', help='output directory and prefix.')
args = parser.parse_args()

table = {"A" : "00", "a" : "00", "C" : "01", 'c' : '01', 'G' : '10', 'g' : '10', 'T' : '11', 't' : '11'}

def toBinary(n, bit):
	return ''.join(str(1 & int(n) >> i) for i in range(bit)[::-1])

def myReadLine(f) :
	ans = f.readline()
	if not ans : return ""

	while ans[-1] == '\n' or ans[-1] == 'r' : ans = ans[:-1]

	return ans

#read T
seqT = None
with open(args.t, 'r') as file_t :
	seqT = myReadLine(file_t)

#write T
with open(args.o + '_t.dat', 'w') as f :
	
	idx = 0
	while idx < len(seqT)  :
		f.write('1_')
		
		if idx + 7 < len(seqT) : f.write('000')
		else : f.write(toBinary(len(seqT) - idx, 3))

		for i in range(7) :
			f.write('_')

			if idx+i < len(seqT) : f.write(table[seqT[idx+i]])
			else : f.write('xx')

		f.write(' //')
		if idx+7 < len(seqT) : f.write(seqT[idx : idx+7])
		else : f.write(seqT[idx:])
		f.write('\n')

		idx += 7

#read S and param
match = []
mismatch = []
alpha = []
beta = []
seqS = []

with open(args.s, 'r') as f :
	temp = myReadLine(f)

	while temp :
		match.append(int(temp))
		mismatch.append(int(myReadLine(f)))
		alpha.append(int(myReadLine(f)))
		beta.append(int(myReadLine(f)))
		seqS.append(myReadLine(f))

		temp = myReadLine(f)

#param
with open(args.o + '_param.dat', 'w') as f :
	for i in range(len(match)) :
		f.write(toBinary(match[i], 4))
		f.write('_')
		f.write(toBinary(mismatch[i], 4))
		f.write('_')
		f.write(toBinary(alpha[i], 8))
		f.write('_')
		f.write(toBinary(beta[i], 8))

		f.write(' //')
		f.write(str(match[i]))
		f.write(' ')
		f.write(str(mismatch[i]))
		f.write(' ')
		f.write(str(alpha[i]))
		f.write(' ')
		f.write(str(beta[i]))
		f.write('\n')

#sequence S
for numS in range(len(seqS)) :
	with open(args.o + '_s_' + str(numS) + '.dat', 'w') as f :
		idx = 0
		while idx < len(seqS[numS]) :
			for i in range(32) :
				if idx + i < len(seqS[numS]) : f.write(table[seqS[numS][idx + i]])
				else : f.write('xx')

				if i & 3 == 3 and i != 31 : f.write('_')

			f.write(' //')
			for i in range(32) :
				if idx + i >= len(seqS[numS]) : break

				if i & 3 == 0 and i != 0 : f.write('_')
				f.write(seqS[numS][idx + i])

			f.write('\n')

			idx += 32

# length os S
with open(args.o + '_lenS.dat', 'w') as f :
	for i in range(len(seqS)) :
		f.write(toBinary(len(seqS[i]), 32))
		f.write(' // ' + str(len(seqS[i])) + '\n')

# number of s
with open(args.o + '_numS.dat', 'w') as f :
	f.write(toBinary(len(seqS), 32))
	f.write(' // ' + str(len(seqS)) + '\n')