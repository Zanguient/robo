//+------------------------------------------------------------------+
//|                                                      Volumes.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Green,Red,Blue
#property indicator_style1  0
#property indicator_width1  1
#property indicator_minimum 0.0
//--- input data
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes
//---- indicator buffers
double                    ExtVolumesBuffer[];
double                    ExtColorsBuffer[];

double MediaZigZagHigh[];
double MediaZigZagLow[];

double topo[4];
double fundo[4];

int contadorTopo = 0;
int contadorFundo = 0;

int mZigZag;

input double diferencaTopoFundo = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- buffers   
   SetIndexBuffer(0,ExtVolumesBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"Volumes");
//---- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   
   mZigZag = iCustom(Symbol(), Period(), "ZigZag", 12, 5, 3);
//----
  }
//+------------------------------------------------------------------+
//|  Volumes                                                         |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  
  
//---check for rates total
   if(rates_total<2)
      return(0);
//--- starting work
   int start=prev_calculated-1;
//--- correct position
   if(start<1) start=1;
//--- main cycle
   if(InpVolumeType==VOLUME_TICK)
      CalculateVolume(start,rates_total,tick_volume);
   else
      CalculateVolume(start,rates_total,volume);
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateVolume(const int nPosition,
                     const int nRatesCount,
                     const long &SrcBuffer[])
  {
   ExtVolumesBuffer[0]=(double)SrcBuffer[0];
   ExtColorsBuffer[0]=0.0;
//---
   
      ExtVolumesBuffer[0]=1;
      
      
      
         ExtColorsBuffer[0]=buscarSinal();
   
//---
  }
//+------------------------------------------------------------------+


int buscarSinal()
{
    ArraySetAsSeries(MediaZigZagHigh, true);
    ArraySetAsSeries(MediaZigZagLow, true);
    

    
    CopyBuffer(mZigZag, 1, 0, 100, MediaZigZagHigh);
    CopyBuffer(mZigZag, 2, 0, 100, MediaZigZagLow);    

    contadorTopo = 0;
    contadorFundo = 0;

    int x;

    for (x = 0; x < 99; x++)
    {
       

        if (contadorTopo < 4)
        {
            if ((MediaZigZagHigh[x] != 0.0))
            {
                //printf("H:" + MediaZigZagHigh[x]);
                topo[contadorTopo] = MediaZigZagHigh[x];
                contadorTopo++;
            }
        }

        if (contadorFundo < 4)
        {
            if ((MediaZigZagLow[x] != 0.0))
            {
                //printf("H:" + MediaZigZagLow[x]);
                fundo[contadorFundo] = MediaZigZagLow[x];
                contadorFundo++;

            }
        }

    }
    
    if (topo[0] > topo[1] 
    && topo[0] - topo[1] > diferencaTopoFundo
    && fundo[0] > fundo[1]
    && fundo[0] - fundo[1] > diferencaTopoFundo
    ) {
    
    return 0;
    
    }
    
    else if (topo[0] < topo[1] 
    && topo[1] - topo[0] > diferencaTopoFundo
    && fundo[0] < fundo[1]
    && fundo[1] - fundo[0] > diferencaTopoFundo
    ) {
    
    return 1;
    }
    
    else return 2;
    
     
    

    

}
