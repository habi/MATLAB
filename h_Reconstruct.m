function ReconstructedImage=h_Reconstruct(Filename,FileNumber,resize,RotCenter,addpath)
% takes an input filename (according to the directory) and reconstructs it
% with iradon. The 'resize'-factor resizes the sinogram, so that the
% calculation is speedier...

%%calc
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';
recdir = [path Filename '/rec' addpath '/'];
sindir = [path Filename '/sin' addpath '/'];
tifdir = [path Filename '/tif' addpath '/'];
FileNumberStr = [ sprintf('%04d',FileNumber)];
RecFilename = [Filename FileNumberStr '.rec.DMP'];

%supress directory already exists message....
[s,mess,messid]=mkdir([recdir]);

%% compute inverse radon transformation
command = ['sin2rec2 ' sindir Filename FileNumberStr '.sin.DMP '...
    recdir ' ' sprintf('%4.2f',RotCenter) ' 0.0 0 0 0 0 4 10 0.6 0 0 0 0 0.0 0.0']
system(command);

% ReconstructedImage = double(readDumpImage(([ recdir RecFilename ])));
% ReconstructedImage = imresize(ReconstructedImage,resize);

%% show image
% figure;
%     imagesc(ReconstructedImage);
%     title([num2str(RecFilename)]);

%% Clear stuff that is not used anymore....
end