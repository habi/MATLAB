clc;clear all;close all;

Iteration(1) = 1;
Iteration(2) = 2;
Iteration(3) = 1;

AmountOfSubScans = 3;

Projections(1) = 20;
Projections(2) = 10;
Projections(3) = 20;

NumDarks = 1;
NumFlats = 2;

for i=1:AmountOfSubScans
    disp([ 'Working on SubScan s' num2str(i) ]);
	for k = 1:NumDarks + NumFlats + Projections(i) + NumFlats
        if k <= NumDarks + NumFlats
            Counter = k;
        elseif ( k > NumDarks + NumFlats && k <= NumDarks + NumFlats + Projections(i) )
            Counter = NumDarks + NumFlats + ( ( k - NumDarks - NumFlats ) * Iteration(i) );
            if i==2
                Counter = Counter - 1;
            end
        else
            Counter = k + ((Iteration(i)-1)*Projections(i));
        end
        SubScan(i).Numbers(k) = (AmountOfSubScans*Counter)-(AmountOfSubScans-i);
    end
end

for i=1:AmountOfSubScans
    Numbers(1:NumDarks+NumFlats+Projections(i)+NumFlats,i)=SubScan(i).Numbers';
end

Numbers
