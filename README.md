# Speech Signal Processing Hw1

## Audio Processing
:::info
- Environment: Mac OS 10+
- IDE: Matlab
- Usage: simply analysis audio
- Prerequirement: Matlab
:::

### Goal
![](https://i.imgur.com/f5hfB0D.png)



### How to run
1. unzip the file hw1.zip
2. open main.m
3. run it
4. A window will pop out and show a figure with six subgraphs (Waveform, Energy, Zero Crossing Rate, Autocorrelation, Pitch, End-Points Detection)

### Description
1. files
    - sample.wav
        - 使用Google語音小姐錄製"語音訊號處理" (16k Hz, mono)
    - main.m
        - 主要程式 用於call其他function
    - hammingWindow.m
        - formula:
        $$ w(n) = \begin{cases}
            0.54-0.46\cos(\frac{2n\pi}{N-1})\ & ,\ 0\ \le\ n\ \le\ N-1\\
            0\ & ,\ others
        \end{cases}$$
        $N\ is\ the\ size\ of\ a\ frame$
    - energy.m
        - formula:
        $$ E_f = \sum_{n=m-N+1}^m x(n)^2 $$
        $m\ is\ the\ frame\ position\\
        N\ is\ the\ number\ of\ points\ in\ a\ frame\\
        x(n)\ is\ the\ value\ of\ audio\ at\ time\ n$
    - zeroCrossingRate.m
        - formula:
        $$ Z_f = \frac{1}{N}\sum_{n=m-N+1}^m C(x(n)*x(n-1)) \\
        C(x) = \begin{cases}
        1\ & ,\ x < 0\\
        0\ & ,\ x \ge 0
        \end{cases}$$
        $m\ is\ the\ frame\ position\\
        N\ is\ the\ number\ of\ points\ in\ a\ frame\\
        x(n)\ is\ the\ value\ of\ audio\ at\ time\ n$
    - sign.m
        - sign(i) = 1, i>=0
        - sign(i) = -1, i<0
    - autocorrelation.m
        - formula:
        $$ A_f = \frac{1}{N}\sum_{n=m-N+k+1}^m [x(n)*w(m-n)]*[x(n-k)*w(m-n+k)]$$
        $m\ is\ the\ frame\ position\\
        N\ is\ the\ number\ of\ points\ in\ a\ frame\\
        k\ is\ the\ biases\\
        x(n)\ is\ the\ value\ of\ audio\ at\ time\ n\\
        w(n)\ is\ the\ window\ function$
    - End-point Detection
        - find the end points of the audio wave
        - procedure:
            1. use energy to find the energy average and variance
            2. Let ITU equal to energy average
            3. 把每一個frame的energy跟ITU比較
            ```
            %find the begin point
            for i = 1:length(E) - 1
                if(E(i) < ITU)
                    if(E(i + 1) > ITU)
                        begin_p = i;
                        break
                    end
                end
            end

            %find the end point
            for j = length(E):-1:2
                if(E(j) < ITU)
                    if(E(j - 1) > ITU)
                        end_p = j;
                        break
                    end
                end
            end
            ```

    - Pitch.m
        - Detect the pitch
        - procedure:
            1. 透過autocorrelation計算週期（兩個波鋒為一個週期）
            2. 再轉為頻率
        
### Results
![](https://i.imgur.com/1Reau8u.png)

### Referrence
[Speech Signal Processing](https://docs.google.com/presentation/d/1rr-5hOAI5uQDl38HdROF0ibypHeLM6qFGCvGwE9ZD3o/edit#slide=id.p1)
