--WINDOWS-I1CG0NU
 IF exists(select * from tempdb..sysobjects where id=object_id('tempdb..#EFF_TB'))
 DROP TABLE #EFF_TB 
 SELECT		
 --NEWID() OBJECTID,
 max(CON_PQ_TB.PQHANDLETIME) as PQHANDLETIME,
 				CON_PQ_TB.EVENT_ID,
 				CON_TGTDSQ_TB.TGTDHANDLETIME,
 				CON_CZWC_TB.CZWCHANDLETIME,
 	 			CON_JA_TB.JAHANDLETIME,
 				CON_TJ_TB.UNIT_ID,
 				CON_PQDW_TB.DEALNEEDTIME 
 --INTO      #EFF_TB
 FROM 
 ( SELECT     PQ_TB.EVENT_ID,(SUBSTRING(PQ_TB.HANDLEOPTION,CHARINDEX(')��',PQ_TB.HANDLEOPTION)+2,CHARINDEX(', Ҫ�󵽳�ʱ�䣺',PQ_TB.HANDLEOPTION)-15)) AS UNITNAME,
   MAX(PQ_TB.HANDLETIME) AS PQHANDLETIME
   FROM       DBO.GT_CHECKFLOW PQ_TB
   WHERE      PQ_TB.ACTION_NAME = '��ǲ'
   		and PQ_TB.HANDLETIME >= '2016-04-01 00:00:00'
   		and PQ_TB.HANDLETIME <= '2016-04-12 23:59:59'
		and PQ_TB.EVENT_ID NOT IN
		(	SELECT    DISTINCT YQZF_TB.EVENT_ID
			FROM      DBO.GT_CHECKFLOW AS YQZF_TB
			WHERE     YQZF_TB.ACTION_NAME IN ('������׼', '��������','��������')
			 AND  YQZF_TB.HANDLETIME <='2016-04-12 23:59:59'
		)  GROUP BY PQ_TB.EVENT_ID,PQ_TB.HANDLEOPTION
 ) CON_PQ_TB
  LEFT JOIN
 ( SELECT     TGTDSQ_TB.EVENT_ID, MAX(TGTDSQ_TB.HANDLETIME) AS TGTDHANDLETIME
   FROM       DBO.GT_CHECKFLOW AS TGTDSQ_TB
   WHERE      TGTDSQ_TB.ACTION_NAME in ('ͨ���˵�����','�˵�')
    		and TGTDSQ_TB.HANDLETIME >= '2016-04-01 00:00:00'
    		and TGTDSQ_TB.HANDLETIME <= '2016-04-12 23:59:59'
    GROUP BY TGTDSQ_TB.EVENT_ID
    ) CON_TGTDSQ_TB ON CON_PQ_TB.EVENT_ID = CON_TGTDSQ_TB.EVENT_ID
  LEFT JOIN
 ( SELECT     CZWC_TB.EVENT_ID, MAX(CZWC_TB.HANDLETIME) AS CZWCHANDLETIME
   FROM       DBO.GT_CHECKFLOW AS CZWC_TB
   WHERE      CZWC_TB.ACTION_NAME ='�������'
    		and CZWC_TB.HANDLETIME >= '2016-04-01 00:00:00'
    		and CZWC_TB.HANDLETIME <= '2016-04-12 23:59:59'
    GROUP BY CZWC_TB.EVENT_ID
    ) CON_CZWC_TB ON CON_PQ_TB.EVENT_ID = CON_CZWC_TB.EVENT_ID
    LEFT JOIN
    ( SELECT     JA_TB.EVENT_ID, JA_TB.HANDLETIME AS JAHANDLETIME
      FROM       DBO.GT_CHECKFLOW AS JA_TB
      WHERE      JA_TB.ACTION_NAME = '�᰸'
   		and JA_TB.HANDLETIME >= '2016-04-01 00:00:00'
   		and JA_TB.HANDLETIME <= '2016-04-12 23:59:59'
    ) CON_JA_TB ON CON_PQ_TB.EVENT_ID = CON_JA_TB.EVENT_ID
    LEFT JOIN
    ( SELECT TJ_TB.UNIT_ID,TJ_TB.Name,TJ_TB.Des
      FROM   DBO.TB_UNIT_TJ AS TJ_TB
     ) CON_TJ_TB ON CON_PQ_TB.UNITNAME = CON_TJ_TB.Des
  LEFT JOIN
  ( SELECT     DISTINCT PQDW_TB.EVENT_ID, Max(PQDW_TB.DEALNEEDTIME) as DEALNEEDTIME
    FROM       DBO.GT_EVENT_DISPATCH AS PQDW_TB
    group by PQDW_TB.EVENT_ID
   ) CON_PQDW_TB ON CON_PQ_TB.EVENT_ID = CON_PQDW_TB.EVENT_ID
   WHERE (CON_PQ_TB.PQHANDLETIME>CON_TGTDSQ_TB.TGTDHANDLETIME OR CON_TGTDSQ_TB.TGTDHANDLETIME IS NULL)
   and (CON_PQ_TB.PQHANDLETIME<CON_CZWC_TB.CZWCHANDLETIME OR CON_CZWC_TB.CZWCHANDLETIME IS NULL)
   --and CON_PQ_TB.EVENT_ID='bca2e18a72864259961cdb5e5800c779'
   --'bca2e18a72864259961cdb5e5800c779'
   --order by CON_PQ_TB.PQHANDLETIME desc
   GROUP BY CON_PQ_TB.EVENT_ID, CON_TGTDSQ_TB.TGTDHANDLETIME, CON_JA_TB.JAHANDLETIME, CON_TJ_TB.UNIT_ID, CON_PQDW_TB.DEALNEEDTIME,CON_CZWC_TB.CZWCHANDLETIME

--EXEC [dbo].[QueryRsltProc] @sTime = N'2016-04-01 00:00:00', @eTime = N'2016-04-13 00:00:00'
--select distinct(aa.EVENT_ID) from #EFF_TB aa
 --select aa.EVENT_ID from #EFF_TB aa group by aa.EVENT_ID having COUNT(aa.event_id)>1
 --select * from #EFF_TB aa where aa.EVENT_ID='bca2e18a72864259961cdb5e5800c779'
 
--select aa.ID as UNITID, aa.Name as ��λ���� ,bb.Ӧ�᰸�� as Ӧ�᰸�� ,cc.�ѽ᰸�� as �ѽ᰸�� ,dd.���ڽ᰸�� as ���ڽ᰸�� ,ee.���ڽ᰸�� as ���ڽ᰸�� ,bb.Ӧ�᰸��-cc.�ѽ᰸�� as ����δ�᰸�� ,aa.��ǲ�� as ��ǲ�� ,CONVERT(DECIMAL(18,2),((case when dd.���ڽ᰸��>bb.Ӧ�᰸�� then bb.Ӧ�᰸�� else dd.���ڽ᰸�� end)*100/(bb.Ӧ�᰸��+0.0000001))) as ���ڽ᰸�� ,CONVERT(DECIMAL(18,2),((case when cc.�ѽ᰸��>bb.Ӧ�᰸�� then bb.Ӧ�᰸�� else cc.�ѽ᰸�� end)*100/(bb.Ӧ�᰸��+0.0000001))) as �᰸�� ,'' as ���� ,GETDATE() as �Ʊ�ʱ��

--from 
--( select a.UNIT_ID as ID,a.Name as Name, count(DISTINCT b.EVENT_ID) as ��ǲ�� from TB_UNIT_TJ a
-- left join ( select DISTINCT Eff.EVENT_ID, Eff.UNIT_ID from #EFF_TB Eff ) b on a.UNIT_ID = b.UNIT_ID group by a.UNIT_ID,a.Name  ) aa inner join ( select a.UNIT_ID as ID,a.Name,count(DISTINCT b.EVENT_ID) as Ӧ�᰸�� from [WxData].[dbo].TB_UNIT_TJ a left join ( select DISTINCT Eff.EVENT_ID, Eff.UNIT_ID from #EFF_TB Eff where DATEDIFF(SECOND,Eff.PQHANDLETIME,'2016-04-12 23:59:59')>=Eff.DEALNEEDTIME+7200 ) b on a.UNIT_ID = b.UNIT_ID group by a.UNIT_ID,a.Name ) bb on aa.ID=bb.ID inner join ( select a.UNIT_ID as ID,a.Name,count(DISTINCT b.EVENT_ID) as �ѽ᰸�� from [WxData].[dbo].TB_UNIT_TJ a left join ( select DISTINCT Eff.EVENT_ID, Eff.UNIT_ID from #EFF_TB Eff where DATEDIFF(SECOND,Eff.PQHANDLETIME,'2016-04-12 23:59:59')>=Eff.DEALNEEDTIME+7200 and Eff.JAHANDLETIME is not null ) b on a.UNIT_ID = b.UNIT_ID group by a.UNIT_ID,a.Name ) cc on bb.ID=cc.ID inner join ( select a.UNIT_ID as ID,a.Name,count(DISTINCT b.EVENT_ID) as ���ڽ᰸�� from [WxData].[dbo].TB_UNIT_TJ a left join ( select DISTINCT Eff.EVENT_ID, Eff.UNIT_ID from #EFF_TB Eff WHERE Eff.JAHANDLETIME is not null AND DATEDIFF(SECOND,Eff.PQHANDLETIME,'2016-04-12 23:59:59')>=Eff.DEALNEEDTIME+7200 AND DATEDIFF(SECOND,Eff.PQHANDLETIME,Eff.JAHANDLETIME)<=Eff.DEALNEEDTIME+7200 ) b on a.UNIT_ID = b.UNIT_ID group by a.UNIT_ID,a.Name ) dd on cc.ID=dd.ID inner join ( select a.UNIT_ID as ID,a.Name,count(DISTINCT b.EVENT_ID) as ���ڽ᰸�� from [WxData].[dbo].TB_UNIT_TJ a left join ( select DISTINCT Eff.EVENT_ID, Eff.UNIT_ID from #EFF_TB Eff WHERE Eff.JAHANDLETIME is not null AND DATEDIFF(SECOND,Eff.PQHANDLETIME,'2016-04-12 23:59:59')>=Eff.DEALNEEDTIME+7200 AND DATEDIFF(SECOND,Eff.PQHANDLETIME,Eff.JAHANDLETIME)>Eff.DEALNEEDTIME+7200 ) b on a.UNIT_ID = b.UNIT_ID group by a.UNIT_ID,a.Name ) ee on dd.ID=ee.ID order by ���ڽ᰸�� desc,Ӧ�᰸�� desc,��ǲ�� desc DROP TABLE #EFF_TB 