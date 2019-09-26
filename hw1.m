% % % 音檔讀入
[y,fs]=audioread('AudioL.wav');
y=y/max(abs(y));
t=(1:length(y))/fs;

% % % Speech Waveform 畫出Waveform圖
subplot(5,1,1);
plot(t,y);
title('Speech Waveform');
xlabel('time in seconds');

% % % 設frameSize數值
ms=32;
frame_size=ms/1000*fs;
frame_shift=frame_size/2;


% % % Short Term energy 照公式計算每個frame中energy總和
energy=0;
t_e=(1:frame_shift:length(y)-frame_shift)/fs;
temp=0;
for i=1:length(t_e)
    for j=((i-1)*frame_shift+1):(i+1)*frame_shift
        if j<=length(y)
            temp=temp+y(j).^2;
        end
    end
    energy(i)=temp;
    temp=0;
end

% % % 畫出energy圖
subplot(5,1,2);
plot(t_e,energy);
title('Energy');
xlabel('time in seconds');

% % % Short Term Zero-crossing Rate 透過前後兩項相乘小於0判斷過零，以此計算過零率
zcr=0;
for i=1:length(t_e)
    for j=((i-1)*frame_shift+2):(i+1)*frame_shift
        if j<=length(y)
            if(y(j-1)*y(j)<0)
                temp=temp+1;
            end
        end
    end
    zcr(i)=temp/(2*frame_size);
    temp=0;
end

% % % 畫出過零率圖
subplot(5,1,3);
plot(t_e,zcr);
title('Zero-crossing Rate');
xlabel('time in seconds');

% % % End Point Detection
% 按照公式算出所需ITU、ITL、IZCT等，在依此從前後去找start與end，並回推250ms做check
IMX=max(energy);
IMN=mean(energy(1:37));
I1=0.03*(IMX-IMN)+IMN;
I2=4*IMN;
ITL=min(I1,I2);
ITU=4*ITL;
IZC=mean(zcr(1:37));
zcrstd=std(zcr(1:37));
IZCT=min(25*0.01,IZC+2*zcrstd);
N1=0;
N2=0;
found=0;
for i=10:length(energy)
    if energy(i)>=ITL
        for j=i:length(energy)
            if energy(j)<ITL
                break
            else
                if energy(j)>=ITU
                    if found==0
                        N1=j;
                        found=1;
                    end
                    break
                end
            end
        end
    end
    if found==1
        break
    end
end
sPoint=max(N1-25,1);
ePoint=N1;
backCheck=0;
for i=sPoint:ePoint
    if zcr(i)>=IZCT
        backCheck=backCheck+1;
    end
end        
if backCheck>=3
    for i=sPoint:ePoint
        if zcr(i)>=IZCT
            N1=i;
            break;
        end
    end
end

found=0;
for i=length(energy):-1:1
    if energy(i)>=ITL
        for j=i:-1:1
            if energy(j)<ITL
                break;
            else
                if energy(j)>=ITU
                    if found==0
                        N2=j;
                        found=1;
                    end
                    break
                end
            end
        end
    end
    if found==1
        break
    end
end
sPoint=max(1,N2);
ePoint=min(N2+25,length(zcr));
backCheck=0;
for i=sPoint:ePoint
    if zcr(i)>=IZCT
        backCheck=backCheck+1;
    end
end
if backCheck>=3
    for i=max(1,sPoint):ePoint
        if zcr(i)>=IZCT
            N2=i;
            break;
        end
    end
end

N1=N1*round(length(y)/length(energy));
N2=N2*round(length(y)/length(energy));

% % % 以紅線劃出start與end point位置
subplot(5,1,4);
plot(t,y);
hold on;
line(t(N1+1)*[1,1],[min(y),max(y)],'color', 'r');
line(t(N2)*[1,1],[min(y),max(y)],'color', 'r');
title('End Point Detection');
xlabel('time in seconds');

% % % Pitch 依公式先做center clipping
cl=0.3*max(abs(y));
x=0;
for i=1:length(y)
    if y(i)>cl
        x(i)=y(i)-cl;
    end
    if y(i)<-1*cl
        x(i)=y(i)+cl;
    end
    if abs(y(i))<=cl
        x(i)=0;
    end
end

% % % 算出clipping後的energy_c
energy_c=0;
t_c=(1:frame_shift:length(x)-frame_shift)/fs;
temp=0;
for i=1:length(t_c)
    for j=((i-1)*frame_shift+1):(i+1)*frame_shift
        if j<=length(x)
            temp=temp+(x(j)*x(j));
        end
    end
    energy_c(i)=temp;
    temp=0;
end

% % % 依公式求R(k)，比對後得到需要的值存放以便畫圖
R=0;
Rn=0;
maxK=1;
for i=1:length(t_e)
    for k=1:frame_shift-1
        Rn(k)=0;
        temp=0;
        for j=((i-1)*frame_shift+1):i*frame_shift
            if (j+k)<=length(y)
                if (j+k)<=(i+1)*frame_shift
                    temp=temp+(x(j)*x(j+k));                    
                end
            end
        end
        Rn(k)=temp;
        if abs(Rn(k))>abs(Rn(maxK))
            maxK=k;
        end
    end
    if (abs(Rn(maxK))>=abs(0.05*energy_c(i)))
        R(i)=maxK+1;
    else
        R(i)=0;
    end
%     R(i)=maxK;
    maxK=1;
end      

% % % 劃出pitch圖
subplot(5,1,5);
plot(t_e,R);
title('Pitch');
xlabel('time in seconds');
