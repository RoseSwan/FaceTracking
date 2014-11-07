VLFEATROOT = '/Users/pfau/vlfeat-0.9.19';
CPDROOT = '/Users/pfau/CPD2';

disp('Setting up VLFEAT')
addpath(VLFEATROOT)
run(fullfile(VLFEATROOT,'toolbox/vl_setup'))

disp('Setting up CPD')
addpath(genpath(CPDROOT))
cpd_make

disp('Loading Movie')
frames = read(VideoReader('MVI_0002.MOV'));
nframes = size(frames,4);

alpha = 1.5;
xm = 1.6;
paretocdf = @(x) 1-(xm./x).^alpha;

% Init full set of options %%%%%%%%%%
opt.method='nonrigid'; % use nonrigid registration
opt.beta=2;            % the width of Gaussian kernel (smoothness)
opt.lambda=3;          % regularization weight

opt.viz=1;              % show every iteration
opt.outliers=0.6;       % noise weight
opt.fgt=0;              % use FGT
opt.normalize=1;        % normalize to unit variance and zero mean before registering (default)
opt.corresp=1;          % compute correspondence vector at the end of registration

opt.max_it=100;         % max number of iterations
opt.tol=1e-10;          % tolerance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fb = vl_sift(im2single(rgb2gray(frames(:,:,:,1))),'PeakThresh',.005);
fb = fb(:,clean_keypoints(fb)); % since we aren't using the keypoint orientation for matching, throw away keypoints that are otherwise identical

% Cell array of keypoints in each frame.
% Each entry has format [id, x, y, scale]
keypoints = {[1:length(fb); fb(1:3,:)]};
max_kp = length(fb);

for i = 2:20
    fa = fb;
    fb = vl_sift(im2single(rgb2gray(frames(:,:,:,i))),'PeakThresh',.005);
    fb = fb(:,clean_keypoints(fb));
    X = [fa(1,:);fa(2,:);paretocdf(fa(3,:))]';
    Y = [fb(1,:);fb(2,:);paretocdf(fb(3,:))]';
    figure(1)
    [Transform, C]=cpd_register(X,Y, opt);
    
    D = clean_corresp(X,Transform.Y,C);
    keypoints{i} = [keypoints{i-1}(1,D(D~=0)), max_kp + (1:nnz(D==0)); ...
                    fb(1:3,D~=0),              fb(1:3,D==0)];
    max_kp = max_kp + nnz(D==0);
end