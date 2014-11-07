VLFEATROOT = '/Users/pfau/vlfeat-0.9.19';
CPDROOT = '/Users/pfau/CPD2';

disp('Setting up VLFEAT')
addpath(VLFEATROOT)
run(fullfile(VLFEATROOT,'toolbox/vl_setup'))

disp('Setting up CPD')
addpath(genpath(CPDROOT))

disp('Loading Movie')
frames = read(VideoReader('MVI_0002.MOV'));
nframes = size(frames,4);

fb = vl_sift(im2single(rgb2gray(frames(:,:,:,1))),'PeakThresh',.005);
fb = fb(:,clean_keypoints(fb)); % since we aren't using the keypoint orientation for matching, throw away keypoints that are otherwise identical

% Cell array of keypoints in each frame.
% Each entry has format [id, x, y, scale]
keypoints = {[1:length(fb); fb(1:3,:)]};
max_kp = length(fb);

for i = 2:10
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