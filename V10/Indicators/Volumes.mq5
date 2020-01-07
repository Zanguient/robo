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
#property indicator_color1  Green,Red
#property indicator_style1  0
#property indicator_width1  1
#property indicator_minimum 0.0
//--- input data
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes
//---- indicator buffers
double                    ExtVolumesBuffer[];
double                    ExtColorsBuffer[];

double                    VolumeCompra  = 0;
double                    VolumeVenda = 0;
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
      CalculateVolume(start,rates_total,tick_volume,open,close);
   else
      CalculateVolume(start,rates_total,volume,open,close);
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateVolume(const int nPosition,
                     const int nRatesCount,
                     const long &SrcBuffer[],
                     const double &open[],
                     const double &close[])
  {
   ExtVolumesBuffer[0]=(double)SrcBuffer[0];
   ExtColorsBuffer[0]=0.0;
//---
   for(int i=nPosition;i<nRatesCount && !IsStopped();i++)
     {
      //--- get some data from src buffer
      
      
      double dPrevVolume=(double)SrcBuffer[i-1];
      double dCurrVolume=(double)SrcBuffer[i] + (double)SrcBuffer[i-1];
      
      //--- calculate indicator
      
      
      
      
      
      //if(dCurrVolume>dPrevVolume)
      if (open[i] < close[i]) VolumeCompra = VolumeCompra + dCurrVolume;         
      else VolumeVenda = VolumeVenda +  dCurrVolume;
      
      //1 vermelho
      //0 verde
      
      if (ExtColorsBuffer[i-1] == 1 && VolumeVenda < VolumeCompra )  {
      
        ExtVolumesBuffer[i] = dCurrVolume;
        ExtColorsBuffer[i]=0.0;
        VolumeCompra = dCurrVolume;
        VolumeVenda = 0;
      
      } 
      
      else if (ExtColorsBuffer[i-1] == 1 && VolumeVenda > VolumeCompra )  {
      
        ExtVolumesBuffer[i] = VolumeVenda;
        ExtColorsBuffer[i]=1.0;
      
      }
      
      else if (ExtColorsBuffer[i-1] == 0 && VolumeVenda > VolumeCompra )  {
      
      
      ExtVolumesBuffer[i] = dCurrVolume;
        ExtColorsBuffer[i]=1.0;
        VolumeCompra = 0;
        VolumeVenda = dCurrVolume;
      
      }   
      
      else if (ExtColorsBuffer[i-1] == 0 && VolumeVenda < VolumeCompra )  {
      
         ExtVolumesBuffer[i] = VolumeCompra;
        ExtColorsBuffer[i]=0.0;
      
      } 
         
         
     
     
     
     /* ExtColorsBuffer[i]=0.0;
         ExtVolumesBuffer[i]= dCurrVolume;
         
         ExtColorsBuffer[i]=1.0;
         ExtVolumesBuffer[i]= dCurrVolume;*/
     
     //if ExtColorsBuffer[i-1] == 1
     
     
    
     
//---
  }
  }
//+------------------------------------------------------------------+
