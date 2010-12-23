n=4    % Number of concentric scans
k=8 % Number of Pixels per Image
% syms n k i
%R = []
for i=0:n,
    ['Iteration|' 'Ideal|' 'Scanned *2 @ 3rd|' 'Ratio|' 'Iter.|' 'Ideal|' 'Scanned *2 @ 3rd, *1.33 @ 4h']
    [ i (k*(2*i-1)) k+(2*k*(floor(i/2))) i (k*(2*i-1)) k+(2*k*(i-1))]
 end