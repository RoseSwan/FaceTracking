clear, close all

VLFEATROOT = '/Users/pfau/vlfeat-0.9.19';

disp('Setting up VLFEAT')
addpath(VLFEATROOT)
run(fullfile(VLFEATROOT,'toolbox/vl_setup'))

disp('Loading Movie')
frames = read(VideoReader('MVI_0002.MOV'));
nframes = size(frames,4);

vidObj = VideoWriter('MVI_0002_SIFT');
vidObj.FrameRate = 30;
vidObj.Quality = 100;
open(vidObj);

set(gcf,'Position',[0 0 size(frames,2) size(frames,1)])
set(gcf,'PaperPositionMode','auto')
image(frames(:,:,:,1));
axis off
xlim([0 size(frames,2)]+0.5)
ylim([0 size(frames,1)]+0.5)
set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
for i = 1:nframes
    f = vl_sift(im2single(rgb2gray(frames(:,:,:,i))),'PeakThresh',.005);
    image(frames(:,:,:,i));
    hold on
    vl_plotframe(f);
    axis off
    xlim([0 size(frames,2)]+0.5)
    ylim([0 size(frames,1)]+0.5)
    hold off
    drawnow
    print(gcf,'-dpng','tmp.png')
    img = imread('tmp.png');
    writeVideo(vidObj,img);
    sprintf('Wrote frame %d\n',i);
end
close(vidObj)
system('rm tmp.png')