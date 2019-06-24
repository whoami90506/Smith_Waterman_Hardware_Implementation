from argparse import ArgumentParser

parser = ArgumentParser(description='A program that convert the data to hardware format.')
parser.add_argument('i', help='input file.')
parser.add_argument('o', help='output directory and prefix.')
args = parser.parse_args()

table = {"A" : "00", "a" : "00", "C" : "01", 'c' : '01', 'G' : '10', 'g' : '10', 'T' : '11', 't' : '11'}

def myReadLine(f) :
	ans = f.readline()
	if not ans : return ""

	while ans[-1] == '\n' or ans[-1] == 'r' : ans = ans[:-1]

	return ans

with open(args.i, 'r') as file_in :
	s = myReadLine(file_in)

	with open(args.o + '_s.dat', 'w') as f :
		idx = 0
		for x in s :
			f.write(table[x])
			idx += 1
			if idx % 64 == 0 : f.write('\n')

		while idx % 64 != 0 :
			f.write('xx')
			idx += 1
	
	with open(args.o + '_s_len.dat', 'w') as f : f.write(str(len(s)) + '\n')

	t = myReadLine(file_in)

	with open(args.o + '_t.dat', 'w') as f :
	
		idx = 0
		while idx < len(t)  :
			f.write('1')
			
			if idx + 7 < len(t) : f.write('000')
			else : f.write(format(len(t) - idx, '03b'))

			for i in range(7) :
				if idx+i < len(t) : f.write(table[t[idx+i]])
				else : f.write('xx')

			f.write('\n')
			idx += 7

	with open(args.o + '_param.dat', 'w') as f :
		f.write(format(int(myReadLine(file_in)), '01x'))
		f.write(format(int(myReadLine(file_in)), '01x'))
		f.write(format(int(myReadLine(file_in)), '01x'))
		f.write(format(int(myReadLine(file_in)), '01x'))
		f.write('\n')
		f.write(format(int(myReadLine(file_in)), '01x'))
		f.write(format(int(myReadLine(file_in)), '01x'))
		f.write(format(int(myReadLine(file_in)), '01x'))
		f.write(format(int(myReadLine(file_in)), '01x'))
