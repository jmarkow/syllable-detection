function sylldet_filterbank_visualize(FILTERBANK,DETECT,PITCH,AUDIO_DATA,AUDIO_FS,varargin)
%

spect_colors='jet';
detect_color='r';
pitch_color='y';
in_band=[];
out_band=[];

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'spect_colors'
			spect_colors=varargin{i+1};
		case 'in_band'
			in_band=varargin{i+1};
		case 'out_band'
			out_band=varargin{i+1};
	end
end

nfilts=length(FILTERBANK.coeffs);

if isempty(in_band)
	in_band=2:2:nfilts;
	out_band=1:2:nfilts;
end

[s,f,t]=zftftb_pretty_sonogram(AUDIO_DATA,AUDIO_FS,'filtering',300,'clipping',[-6 2],'len',70,'overlap',69.2);

ax(1)=subplot(1,4,1:3);
imagesc(t,f/1e3,s);axis xy;
colormap(spect_colors);
ylim([0 10]);
set(gca,'TickDir','out','TickLength',[0 0],'YTick',[0:2:10]);
hold on;
plot(DETECT.t,DETECT.sig_smooth.*3,'r-','color',detect_color);
plot(PITCH.t,PITCH.est/1e3,'y-','color',pitch_color);

xlabel('Time (s)');
ylabel('Freq. (kHz)');

ax(2)=subplot(1,4,4);
plot(20*log10(abs(FILTERBANK.freqz.amp(:,in_band))),FILTERBANK.freqz.f/1e3,'b-')
hold on;
plot(20*log10(abs(FILTERBANK.freqz.amp(:,out_band))),FILTERBANK.freqz.f/1e3,'r-')
xlabel('Amplitude (dB)');box off;


set(gca,'ytick',[]);
xlim([-30 1]);
ylim([0 10e3]);
linkaxes(ax,'y');
