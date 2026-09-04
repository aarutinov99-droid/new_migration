-- PROCEDURE: eor.pr_eor_pdl_load(integer)

-- DROP PROCEDURE IF EXISTS eor.pr_eor_pdl_load(integer);

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_load(
	IN p_id_process_log integer)
LANGUAGE 'plpgsql'
AS $BODY$

DECLARE

   /* Регламентный процесс загрузки публичных должностных лиц в спецреестр */

   l_process            varchar(100) := 'PR_EOR_PDL_LOAD_PG';
   l_procedure          varchar(100) := 'pr_eor_pdl_load';
   l_sr_type_id         bigint := 145;
   l_source_id          bigint := 2070;

   l_process_data       eor.idw_rco_process_state%rowtype;
   l_batch_size         bigint;
   l_cnt                bigint;-- := 0;
   l_err_cnt            bigint;-- := 0;
   l_error_sign         varchar(1);-- := '0';
   l_id                 varchar(100);
   l_start_date         timestamp;
   --l_end_date           timestamp;
   l_sr_subject_id      bigint;
   l_sr_subject_count   bigint;

  c RECORD;

BEGIN
      --CALL rco_benchmark.benchmark_start(l_process);
      l_cnt := 0;
      l_err_cnt := 0;

      --=====================================================================
      --1. ЗАГРУЗКА В ОПЕРАТИВНЫЙ СЛОЙ
      --=====================================================================
      for c
         in (SELECT rowid as object_id,
                    a.load_id,
                    a.updated_at,
                    a.system_id,
                    upper(trim(both a.full_name)) full_name,
                    case
                       when idwh2.is_date(a.date_birthday, 'dd.mm.yyyy') = 1
                       then
                          to_date(a.date_birthday, 'dd.mm.yyyy')
                       when idwh2.is_date(a.date_birthday, 'yyyy-mm-dd') = 1
                       then
                          to_date(a.date_birthday, 'yyyy-mm-dd')
                       else
                          null
                    end
                       date_birthday,
                    case
                       when idwh2.is_date(a.date_death, 'dd.mm.yyyy') = 1
                       then
                          to_date(a.date_death, 'dd.mm.yyyy')
                       when idwh2.is_date(a.date_death, 'yyyy-mm-dd') = 1
                       then
                          to_date(a.date_death, 'yyyy-mm-dd')
                       else
                          null
                    end
                       date_death,
                    a.birth_place,
                    case when upper(a.dead) = 'TRUE' then 1 else 0 end
                       is_dead,
                    case
                       when upper(a.gender) = 'M' then 'M'
                       when upper(a.gender) = 'F' then 'F'
                       else null
                    end
                       gender,
                    a.position,
                    a.authority,
                    a.country_names,
                    a.countries,
                    substr (
                       upper ((select string_agg(name, '; ' order by name)
                             from (select rd.name,
                                          sum(
                                             length(rd.name) + 1)
                                          over (
                                             order by rd.name
                                             rows between unbounded preceding
                                                  and     current row)
                                             length
                                     from (select coalesce(
                                                     sa.full_name,
                                                        sa.first_name
                                                     || ' '
                                                     || sa.last_name
                                                     || ' '
                                                     || sa.middle_name)
                                                     name
                                             from idwh2.idw_arj_pdl_names sa
                                            where     sa.load_id = a.load_id
                                                  and sa.system_id =
                                                         a.system_id) rd) alias19
                            where length <= 2000)),
                       1,
                       4000)
                       c_names,
                    substr (
                       upper ((select string_agg(sa.translit_names, '; ' order by sa.translit_names)
                             from idwh2.idw_arj_pdl_translit_names sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_translit_names,
                    substr (
                       upper ((select string_agg(name, '; ' order by name)
                             from (select r.name,
                                          sum(
                                             length(r.name) + 1)
                                          over (
                                             order by r.name
                                             rows between unbounded preceding
                                                  and     current row)
                                             length
                                     from    idwh2.idw_arj_pdl_categories sa
                                          inner join
                                             idwh2.idw_pdl_ref r
                                          on     r.code = sa.category_code
                                             and r.ref_name = 'CATEGORIES'
                                    where     sa.load_id = a.load_id
                                          and sa.system_id = a.system_id) alias31
                            where length <= 4000)),
                       1,
                       4000)
                       c_categories,
                    substr (
                       upper ((select string_agg(name, '; ' order by name)
                             from (select r.name,
                                          sum(
                                             length(r.name) + 1)
                                          over (
                                             order by r.name
                                             rows between unbounded preceding
                                                  and     current row)
                                             length
                                     from    idwh2.idw_arj_pdl_category407 sa
                                          inner join
                                             idwh2.idw_pdl_ref r
                                          on     r.code = sa.category_code
                                             and r.ref_name = 'CATEGORIES407'
                                    where     sa.load_id = a.load_id
                                          and sa.system_id = a.system_id) alias39
                            where length <= 4000)),
                       1,
                       4000)
                       c_categories407,
                    substr (
                       upper ((select string_agg(sa.authority, '; ' order by sa.authority)
                             from idwh2.idw_arj_pdl_jobs sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_jobs,
                    substr (
                       upper ((select string_agg(sa.sanlist, '; ' order by sa.sanlist)
                             from idwh2.idw_arj_pdl_sanlists sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_sanlists,
                    substr (
                       upper ((select string_agg(sa.sanction, '; ' order by sa.sanction)
                             from idwh2.idw_arj_pdl_sanctions sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_sanctions,
                    substr (
                       upper ((select string_agg(sa.country_name, '; ' order by sa.country_name)
                             from idwh2.idw_arj_pdl_countries sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_countries
               from idwh2.idw_arj_interfax_pdl a
              where     a.sr_subject_id = 0
                    and CASE WHEN a.err_msg IS NULL THEN  '0'  ELSE '1' END  = l_error_sign
                    and trim(both a.full_name) not in ('Child', 'Husb')
                    and trim(both a.full_name) is not null
                    and rowid not in (select object_id
                              from idw_sy_workflow_error
                             where     workflow_id =
                                          l_process_data.workflow_id
                                   and state_id = l_process_data.state_id)  LIMIT (l_process_data.batch_size))
      loop
         savepoint pr_eor_pdl_load;

         begin
            l_id := c.object_id;
           -- CALL rco_helper.log(l_process || 'Загрузка system_id = ' || c.system_id || '  l_id = '|| l_id, l_procedure);

            --=====================================================================
            --Поиск по System_ID в Спецреестре ПДЛ (EOR.SR_SUBJECT_PDL)
            --Проставим найденный ИД спецреестра в архибную запись
            --Данные в спецреестре обновим, считаем что данные более верные
            --=====================================================================
            select count(1)
              into STRICT l_sr_subject_count
              from    eor.sr_subject_pdl dst
                   join
                      eor.sr_subject s
                   on s.sr_subject_id = dst.sr_subject_id
             where     dst.system_id = c.system_id
                   and s.sr_type_id = l_sr_type_id;

            if l_sr_subject_count > 0
            then
               --Ид спецреестра
               select dst.sr_subject_id
                 into STRICT l_sr_subject_id
                 from eor.sr_subject_pdl dst
                where dst.system_id = c.system_id  LIMIT 1;

               --Обновим субъекта новыми данными
               update eor.sr_subject_pdl dst
                  set dst.is_eor_ident_process = 0, ---------Для процесса идентификации
                      dst.update_date = clock_timestamp(),
                      --NVL (
                      --   TO_DATE (c.updated_at,
                      --           'yyyy-mm-dd hh24:mi:ss" UTC"'),
                      --  dst.update_date),
                      dst.death_date = coalesce(c.date_death, dst.death_date),
                      dst.is_death = coalesce(c.is_dead, dst.is_death),
                      dst.birth_place = coalesce(c.birth_place, dst.birth_place),
                      dst.gender = coalesce(c.gender, dst.gender),
                      dst.names = coalesce(c.c_names, dst.names),
                      dst.translit_names =
                         coalesce(c.c_translit_names, dst.translit_names),
                      dst.countries = coalesce(c.c_countries, dst.countries),
                      dst.categories = coalesce(c.c_categories, dst.categories),
                      dst.categories407 =
                         coalesce(c.c_categories407, dst.categories407),
                      dst.jobs = coalesce(c.c_jobs, dst.jobs),
                      dst.sanlists = coalesce(c.c_sanlists, dst.sanlists),
                      dst.sanctions = coalesce(c.c_sanctions, dst.sanctions),
                      dst.position = coalesce(c.position, dst.position),
                      dst.authority = coalesce(c.authority, dst.authority),
                      dst.date_birthday =
                         coalesce(c.date_birthday, dst.date_birthday),
                      dst.full_name = coalesce(c.full_name, dst.full_name)
                where dst.sr_subject_id = l_sr_subject_id;
                CALL rco_helper.log(l_process || 'Обновление system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, l_procedure);
           else
               --подвал (Особенность спецреестра)
               insert into eor.sr_subject_pdl(sr_subject_id,
                                               update_date,
                                               death_date,
                                               is_death,
                                               birth_place,
                                               gender,
                                               names,
                                               translit_names,
                                               countries,
                                               categories,
                                               categories407,
                                               jobs,
                                               sanlists,
                                               sanctions,
                                               position,
                                               authority,
                                               system_id,
                                               date_birthday,
                                               full_name,
                                               is_eor_ident_process)
                    values (
                              nextval('sr_subject_seq'),
                              to_date(c.updated_at,
                                       'yyyy-mm-dd hh24:mi:ss" UTC"'),
                              c.date_death,
                              c.is_dead,
                              c.birth_place,
                              c.gender,
                              c.c_names,
                              c.c_translit_names,
                              c.c_countries,
                              c.c_categories,
                              c.c_categories407,
                              c.c_jobs,
                              c.c_sanlists,
                              c.c_sanctions,
                              c.position,
                              c.authority,
                              c.system_id,
                              c.date_birthday,
                              c.full_name,
                              0)
                 returning sr_subject_id
                      into l_sr_subject_id;
                 CALL rco_helper.log(l_process || 'Вставка system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, l_procedure);
           end if;

            --проставим ИД Субъекта Спецреестра в архивный слой
            update idwh2.idw_arj_interfax_pdl a
               set a.sr_subject_id = coalesce(l_sr_subject_id, 0),
                   a.date_load = clock_timestamp(),
                   a.err_msg  = NULL
             where rowid = c.object_id and a.sr_subject_id = 0;

            l_cnt := l_cnt + 1;

            delete from idw_sy_workflow_error
                  where     workflow_id = l_process_data.workflow_id
                        and state_id = l_process_data.state_id
                        and object_id = c.object_id;

           --CALL rco_helper.log(l_process || 'выполнено system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, l_procedure);
           --выход, если превышено количество обработанных объектов в пачке
            exit when l_cnt >= l_batch_size;
         exception
            when others
            then
               null;
              /* CALL idwh2.pkg_eor_aux.save_error(
                  l_id,
                  l_process_data.workflow_id,
                  l_process_data.state_id,
                  SQLSTATE,
                  sqlerrm,
                  dbms_utility.format_error_backtrace);*/
               --rollback to pr_eor_pdl_load;
               --l_err_cnt := l_err_cnt + 1;
         end;
      end loop;

      --commit;

--      CALL rco_helper.log(l_process || ' items processed ' || l_cnt, l_procedure);
   end;
/*begin
   -- читаем настройки процесса
   select *
     into STRICT l_process_data
     from idw_rco_process_state
    where process_alias = l_process;

   l_batch_size := l_process_data.batch_size;

   CALL rco_helper.log('start of ' || l_process, l_procedure);

   -- проверяем, не много ли накопилось ошибок
   select count(1)
     into STRICT l_err_cnt
     from idw_sy_workflow_error
    where     workflow_id = l_process_data.workflow_id
          and state_id = l_process_data.state_id;

   if     l_err_cnt >= l_process_data.max_error
      and pkg_rco_process.can_run(l_process) <> 2
   then
      --===========================================================================================
      -- Если накопилось много ошибок, то выводим сообщение в диспетчере!!!
      --===========================================================================================
           CALL idwh2.pkg_log.write_error(
                p_id_process_log => p_id_process_log,
                p_message        => 'Накопилось много ошибок!!! Запустите процесс "'||l_process||'" в режиме обработки ошибок!' ,
                p_call_stack     => 'Накопилось много ошибок ('||l_err_cnt||')!!! В таблице IDWH2.IDW_RCO_PROCESS_STATE для процесса "'||l_process||'" максимальное кол-во ошибок '||l_process_data.max_error||'!',
                p_comments       => 'Ошибки данных');
      CALL rco_helper.log(l_process || ' too many errors! exiting', l_procedure);
      return;
   end if;

  <<next_portion>>
   null;

   -- проверяем, не помечен ли
   if not pkg_rco_process.can_run(l_process) in (1, 2)
   then
      CALL rco_helper.log(l_process || ' marked to stop by user! exiting',
                      l_procedure);
      return;
   end if;

   if pkg_rco_process.can_run(l_process) = 2
   then
      l_error_sign := '1';
      l_batch_size := 1;
      CALL rco_helper.log(l_process || ' error processing mode', l_procedure);
   else
      l_error_sign := '0';
      l_batch_size := l_process_data.batch_size;
      CALL rco_helper.log(l_process || ' normal processing mode', l_procedure);
   end if;

   -- обрабатываем порцию
   l_start_date := clock_timestamp();

   CALL process_batch();

   l_end_date := clock_timestamp();
   CALL idwh2.process_info_log_wm(p_id_process_log   => p_id_process_log,
                              p_start_date       => l_start_date,
                              p_end_date         => l_end_date,
                              p_process_sign     => l_error_sign,
                              p_batch_size       => l_batch_size,
                              p_rows_count       => l_cnt,
                              p_errors_count     => l_err_cnt,
                              p_comments         => '');


   -- ничего не обработали, выходим
   if l_cnt = 0
   then
      CALL rco_helper.log(l_process || ' no more items! exiting', l_procedure);
      return;
   end if;

   select count(1)
     into STRICT l_err_cnt
     from idw_sy_workflow_error
    where     workflow_id = l_process_data.workflow_id
          and state_id = l_process_data.state_id;

   -- накопилось много ошибок, выходим
   if l_err_cnt >= l_process_data.max_error
   then
      --===========================================================================================
      -- Если накопилось много ошибок, то выводим сообщение в диспетчере!!!
      --===========================================================================================
           CALL idwh2.pkg_log.write_error(
                p_id_process_log => p_id_process_log,
                p_message        => 'Накопилось много ошибок!!! Запустите процесс "'||l_process||'" в режиме обработки ошибок!' ,
                p_call_stack     => 'Накопилось много ошибок ('||l_err_cnt||')!!! В таблице IDWH2.IDW_RCO_PROCESS_STATE для процесса "'||l_process||'" максимальное кол-во ошибок '||l_process_data.max_error||'!',
                p_comments       => 'Ошибки данных');
      CALL rco_helper.log(l_process || ' too many errors! exiting', l_procedure);
      return;
   end if;

   goto next_portion;
end;*/
$BODY$;
ALTER PROCEDURE eor.pr_eor_pdl_load(integer)
    OWNER TO r_fors_db_owner;

