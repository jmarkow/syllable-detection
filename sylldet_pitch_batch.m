function [PITCH_MATRIX,T]=sylldet_fir_learn(AUDIO,FS,varargin)
% get pitch of sounds in a batch
%

if ~isa(AUDIO,'double')
	AUDIO=double(AUDIO);
end

len=20;
overlap=18;
method='z';

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'len'
			len=varargin{i+1};
		case 'overlap'
			overlap=varargin{i+1};
		case 'method'
			method=varargin{i+1};
	end
end

[nsamples,ntrials]=size(AUDIO);

% get pitch of first trial

len_smps=round((len/1e3)*FS);
overlap_smps=round((overlap/1e3)*FS);
step_size=len_smps-overlap_smps;

steps=1:step_size:nsamples-len_smps;
nsteps=length(steps);

PITCH_MATRIX=zeros(nsteps,ntrials);
T=(steps+len)/FS;

reverse_string='';

for i=1:ntrials

	percent_complete=100 * (i/ntrials);
	msg=sprintf('Percent done: %3.1f',percent_complete);
	fprintf([reverse_string,msg]);
	reverse_string=repmat(sprintf('\b'),1,length(msg));

	switch lower(method(1))

		case 'a'

			PITCH_MATRIX(:,i)=sylldet_pitch_autocorr(AUDIO(:,i),FS,'len',len,'overlap',overlap,varargin{:});
		case 'c'

			PITCH_MATRIX(:,i)=sylldet_pitch_cepstrum(AUDIO(:,i),FS,'len',len,'overlap',overlap,varargin{:});

		case 'z'

			PITCH_MATRIX(:,i)=sylldet_pitch_zcross(AUDIO(:,i),FS,'len',len,'overlap',overlap,varargin{:});

		otherwise 
		
	end

end

fprintf('\n');

