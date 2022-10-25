with serie as --//Serie de fechas desde este mes hasta 2 años atras
(select generate_series
(date((extract(year from date(now())-1)-1)::text||'-01-01')::timestamp,
date((extract(year from date(now())-1)+1)::text||'-01-01')::timestamp,
interval '1 day'
)::date-1 as fecha)
,feriados as --//Tabla API Feriados
(select distinct
fecha::date as fecha
,nombre as nombre_feriado
,tipo as tipo
from api_feriados af
where nombre not like '%Domingo%'
group by
fecha
,nombre
,tipo
order by fecha desc)
select --//select General
serie.fecha
,case
when serie.fecha >= '2020-12-31' and serie.fecha<='2021-01-03' then 797.96
when serie.fecha < now() then
coalesce(
coalesce(
coalesce(
coalesce(
coalesce(
coalesce(valor_dolar::numeric,
lag(valor_dolar::numeric,1) over (ORDER BY serie.fecha)),
lag(valor_dolar::numeric,2) over (ORDER BY serie.fecha)),
lag(valor_dolar::numeric,3) over (ORDER BY serie.fecha)),
lag(valor_dolar::numeric,4) over (ORDER BY serie.fecha)),
lag(valor_dolar::numeric,5) over (ORDER BY serie.fecha)),0)
end as valor_dolar
,case
when serie.fecha >= '2020-12-31' and serie.fecha<='2021-01-03' then 880.26
when serie.fecha < now() then
coalesce(
coalesce(
coalesce(
coalesce(
coalesce(
coalesce(valor_euro::numeric,
lag(valor_euro::numeric,1) over (ORDER BY serie.fecha)),
lag(valor_euro::numeric,2) over (ORDER BY serie.fecha)),
lag(valor_euro::numeric,3) over (ORDER BY serie.fecha)),
lag(valor_euro::numeric,4) over (ORDER BY serie.fecha)),
lag(valor_euro::numeric,5) over (ORDER BY serie.fecha)),0)
end as valor_euro
,uf.valor_uf::numeric
,case when serie.fecha<now() then utm.valor_utm end as valor_utm
,ipc.valor_ipc
,f.nombre_feriado
from serie
left join dolar_diario as dolar_diario --//Tabla Dolar Diario
on date(dolar_diario.fecha) = serie.fecha
left join uf_diario as uf --//Tabla UF Diario
on date(uf.fecha) = serie.fecha
left join euro_diario as euro --//Tabla Euro Diario
on date(euro.fecha) = serie.fecha
left join utm as utm --/Tabla UTM Mensual
on date_trunc('month',utm.fecha) = date_trunc('month',serie.fecha)
left join ipc as ipc --//Tabla IPC Mensual
on date_trunc('month',ipc.fecha) = date_trunc('month',serie.fecha)
left join feriados as f --//Subtabla Feriados
on f.fecha = serie.fecha
order by serie.fecha desc
