function ReconstructedImage=h_Reconstruct(Filename,FileNumber,resize,RotCenterShift)
% takes an input filename (according to the directory) and reconstructs it
% with iradon. The 'resize'-factor resizes the sinogram, so that the
% calculation is speedier...

path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';
recdir = [path Filename '/rec/'];
sindir = [path Filename '/sin/'];
tifdir = [path Filename '/tif/'];

FileNumberStr = [ sprintf('%04d',FileNumber)];
RecFilename = [Filename FileNumberStr '.rec.tif'];
SinFilename = [Filename FileNumberStr '.sin.DMP'];

%supress directory already exists message....
[s,mess,messid]=mkdir([recdir]);

%% load sinograms
% load = [ sindir num2str(SinFilename) ]
Sinogram = double(readDumpImage(([ sindir num2str(SinFilename) ])));
SinogramSize = size(Sinogram);

%% correct rotation center
Sinogram = h_CorrectRotCenter(Sinogram,RotCenterShift);

%% resize if desired, as specified by input-parameter
if resize ==1
else
    Sinogram = imresize(Sinogram,resize); %B = imresize(A,m) returns image B that is m times the size of A.
end

%% rotate Sinogram so that it's the MATLAB-way
Sinogram = Sinogram'; 
SinogramSize = size(Sinogram);

%% compute inverse radon transformation
theta = 0:180/(SinogramSize(2)-1):180;
ReconstructedImage = iradon(Sinogram,theta,'linear','Shepp-Logan');

%% normalize image
% values from RecoManager
lowbound = 0;
highbound = 1;

%values from MATLAB
MinValue = min(min(ReconstructedImage))
MaxValue = max(max(ReconstructedImage))

lowbound = -0.8398;
highbound = 2.2663;

low = find(ReconstructedImage < lowbound);% = ReconstructedImage - min(min(ReconstructedImage));
high = find(ReconstructedImage > highbound);% = ReconstructedImage / max(max(ReconstructedImage));

ReconstructedImage(low) = lowbound;
ReconstructedImage(high) = highbound;

ReconstructedImage = ReconstructedImage - lowbound;
ReconstructedImage = ReconstructedImage ./ (highbound - lowbound) * 65535; % 16bit Skalierung

%% show image
% figure;
%     imshow(ReconstructedImage,[]);
%     title(['Reconstruction from ' num2str(SinFilename)]);
% save = [recdir '/' RecFilename]

%% save image
imwrite(uint16(ReconstructedImage),[recdir '/' RecFilename],'Compression','none'); 

%% Clear stuff that is not used anymore....
clear ReconstructedImage;
clear Sinogram;

end