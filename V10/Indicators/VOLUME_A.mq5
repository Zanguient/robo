//+------------------------------------------------------------------+
//|                                                     VOLUME_A.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Weis Volume Waves"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_width1  4
#property indicator_color1  clrGreen, clrRed

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

double bufferWW[];
double bufferColors[];





int OnInit()
  {
//--- indicator buffers mapping


    SetIndexBuffer( 0, bufferWW, INDICATOR_DATA );
    SetIndexBuffer( 1, bufferColors, INDICATOR_COLOR_INDEX );
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
