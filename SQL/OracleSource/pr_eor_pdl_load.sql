CREATE OR REPLACE procedure IDWH2.pr_eor_pdl_load (p_id_process_log number)
as
   /* Регламентный процесс загрузки публичных должностных лиц в спецреестр */
   l_process            varchar2 (100) := 'PR_EOR_PDL_LOAD';
   l_procedure          varchar2 (100) := 'pr_eor_pdl_load';
   l_sr_type_id         number := 145;
   l_source_id          number := 2070;

   l_process_data       idw_rco_process_state%rowtype;
   l_batch_size         number;
   l_cnt                number := 0;
   l_err_cnt            number := 0;
   l_error_sign         varchar2 (1 byte) := '0';
   l_id                 varchar2 (100);
   l_start_date         date;
   l_end_date           date;
   l_sr_subject_id      numeric;
   l_sr_subject_count   numeric;

   procedure process_batch
   as
   begin
      rco_benchmark.benchmark_start (l_process);
      l_cnt := 0;
      l_err_cnt := 0;

      --=====================================================================
      --1. ЗАГРУЗКА В ОПЕРАТИВНЫЙ СЛОЙ
      --=====================================================================
      for c
         in (select rowid as object_id,
                    a.load_id,
                    a.updated_at,
                    a.system_id,
                    upper (trim (a.full_name)) full_name,
                    case
                       when idwh2.is_date (a.date_birthday, 'dd.mm.yyyy') = 1
                       then
                          to_date (a.date_birthday, 'dd.mm.yyyy')
                       when idwh2.is_date (a.date_birthday, 'yyyy-mm-dd') = 1
                       then
                          to_date (a.date_birthday, 'yyyy-mm-dd')
                       else
                          null
                    end
                       date_birthday,
                    case
                       when idwh2.is_date (a.date_death, 'dd.mm.yyyy') = 1
                       then
                          to_date (a.date_death, 'dd.mm.yyyy')
                       when idwh2.is_date (a.date_death, 'yyyy-mm-dd') = 1
                       then
                          to_date (a.date_death, 'yyyy-mm-dd')
                       else
                          null
                    end
                       date_death,
                    a.birth_place,
                    case when upper (a.dead) = 'TRUE' then 1 else 0 end
                       is_dead,
                    case
                       when upper (a.gender) = 'M' then 'M'
                       when upper (a.gender) = 'F' then 'F'
                       else null
                    end
                       gender,
                    a.position,
                    a.authority,
                    a.country_names,
                    a.countries,
                    substr (
                       upper (
                          (select listagg (name, '; ')
                                     within group (order by name)
                             from (select rd.name,
                                          sum (
                                             length (rd.name) + 1)
                                          over (
                                             order by rd.name
                                             rows between unbounded preceding
                                                  and     current row)
                                             length
                                     from (select coalesce (
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
                                                         a.system_id) rd)
                            where length <= 2000)),
                       1,
                       4000)
                       c_names,
                    substr (
                       upper (
                          (select listagg (sa.translit_names, '; ')
                                  within group (order by sa.translit_names)
                             from idwh2.idw_arj_pdl_translit_names sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_translit_names,
                    substr (
                       upper (
                          (select listagg (name, '; ')
                                     within group (order by name)
                             from (select r.name,
                                          sum (
                                             length (r.name) + 1)
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
                                          and sa.system_id = a.system_id)
                            where length <= 4000)),
                       1,
                       4000)
                       c_categories,
                    substr (
                       upper (
                          (select listagg (name, '; ')
                                     within group (order by name)
                             from (select r.name,
                                          sum (
                                             length (r.name) + 1)
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
                                          and sa.system_id = a.system_id)
                            where length <= 4000)),
                       1,
                       4000)
                       c_categories407,
                    substr (
                       upper (
                          (select listagg (sa.authority, '; ')
                                     within group (order by sa.authority)
                             from idwh2.idw_arj_pdl_jobs sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_jobs,
                    substr (
                       upper (
                          (select listagg (sa.sanlist, '; ')
                                     within group (order by sa.sanlist)
                             from idwh2.idw_arj_pdl_sanlists sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_sanlists,
                    substr (
                       upper (
                          (select listagg (sa.sanction, '; ')
                                     within group (order by sa.sanction)
                             from idwh2.idw_arj_pdl_sanctions sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_sanctions,
                    substr (
                       upper (
                          (select listagg (sa.country_name, '; ')
                                     within group (order by sa.country_name)
                             from idwh2.idw_arj_pdl_countries sa
                            where     sa.load_id = a.load_id
                                  and sa.system_id = a.system_id)),
                       1,
                       4000)
                       c_countries
               from idwh2.idw_arj_interfax_pdl a
              where a.sr_subject_id = 0
                    and decode (a.err_msg, null, '0', '1') = l_error_sign
                    and trim (a.full_name) not in ('Child', 'Husb')
                    and trim (a.full_name) is not null
                    and ( --Если нет категории, то не должнен быть заполнен санкционный список  --Николаева
                     ( not exists( select 1
                                 from idwh2.idw_arj_pdl_categories cat
                                 where cat.load_id = a.load_id
                                 and cat.system_id = a.system_id
                                 and (cat.category_code is not null)
                                 )
                   and not exists( select 1 --
                              from idwh2.idw_arj_pdl_sanlists sl
                              where sl.load_id = a.load_id
                              and sl.system_id = a.system_id
                              and sl.sanlist is not null
                             ))
                    or
                    exists( select 1 --Или есть категория, кроме санкций  --Николаева
                                 from idwh2.idw_arj_pdl_categories cat
                                 where cat.load_id = a.load_id
                                 and cat.system_id = a.system_id
                                 and cat.category_code is not null
                                 and trim(upper(cat.category_code)) not in ('SANCTION','EX_SANCTION','CLOSEST_SAN')
                            )
                    )
                    and rowid not in
                           (select object_id
                              from idw_sy_workflow_error
                             where     workflow_id =
                                          l_process_data.workflow_id
                                   and state_id = l_process_data.state_id)
                    and rownum <= l_process_data.batch_size
                    -- РФМ.ЕИС.0767:BGN
                    AND NOT EXISTS(
                        SELECT 'X'
                        FROM IDWH2.IDW_ARJ_PDL_SANLISTS SL
                        WHERE     
                                SL.LOAD_ID = A.LOAD_ID
                            AND SL.SYSTEM_ID = A.SYSTEM_ID
                            AND UPPER(SL.SANLIST) LIKE '%РОСФИНМОНИТОРИНГ%'
                    )
                    -- РФМ.ЕИС.0767:END 
            )
      loop
         savepoint pr_eor_pdl_load;

         begin
            l_id := c.object_id;
            rco_helper.log(l_process || 'Загрузка system_id = ' || c.system_id || '  l_id = '|| l_id, l_procedure);

            --=====================================================================
            --Поиск по System_ID в Спецреестре ПДЛ (EOR.SR_SUBJECT_PDL)
            --Проставим найденный ИД спецреестра в архибную запись
            --Данные в спецреестре обновим, считаем что данные более верные
            --=====================================================================

            select count (1)
              into l_sr_subject_count
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
                 into l_sr_subject_id
                 from eor.sr_subject_pdl dst
                where dst.system_id = c.system_id and rownum = 1;

               --Обновим субъекта новыми данными
               update eor.sr_subject_pdl dst
                  set dst.is_eor_ident_process = 0, ---------Для процесса идентификации
                      dst.update_date = sysdate,
                      --NVL (
                      --   TO_DATE (c.updated_at,
                      --           'yyyy-mm-dd hh24:mi:ss" UTC"'),
                      --  dst.update_date),
                      dst.death_date = nvl (c.date_death, dst.death_date),
                      dst.is_death = nvl (c.is_dead, dst.is_death),
                      dst.birth_place = nvl (c.birth_place, dst.birth_place),
                      dst.gender = nvl (c.gender, dst.gender),
                      dst.names = nvl (c.c_names, dst.names),
                      dst.translit_names =
                         nvl (c.c_translit_names, dst.translit_names),
                      dst.countries = nvl (c.c_countries, dst.countries),
                      dst.categories = nvl (c.c_categories, dst.categories),
                      dst.categories407 =
                         nvl (c.c_categories407, dst.categories407),
                      dst.jobs = nvl (c.c_jobs, dst.jobs),
                      dst.sanlists = nvl (c.c_sanlists, dst.sanlists),
                      dst.sanctions = nvl (c.c_sanctions, dst.sanctions),
                      dst.position = nvl (c.position, dst.position),
                      dst.authority = nvl (c.authority, dst.authority),
                      dst.date_birthday =
                         nvl (c.date_birthday, dst.date_birthday),
                      dst.full_name = nvl (c.full_name, dst.full_name)
                where dst.sr_subject_id = l_sr_subject_id;
                rco_helper.log(l_process || 'Обновление system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, l_procedure);
           else
               --подвал (Особенность спецреестра)
               insert into eor.sr_subject_pdl (sr_subject_id,
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
                              eor.sr_subject_seq.nextval,
                              --to_date (c.updated_at,
                              --         'yyyy-mm-dd hh24:mi:ss" UTC"'),
                              to_date(substr(c.updated_at, 1, 10) || ' ' ||  substr(c.updated_at, 12, 8), 'yyyy-mm-dd hh24:mi:ss'),
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
                 rco_helper.log(l_process || 'Вставка system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, l_procedure);
           end if;

            --проставим ИД Субъекта Спецреестра в архивный слой
            update idwh2.idw_arj_interfax_pdl a
               set a.sr_subject_id = nvl (l_sr_subject_id, 0),
                   a.date_load = sysdate,
                   a.err_msg = null
             where rowid = c.object_id and a.sr_subject_id = 0;

            l_cnt := l_cnt + 1;

            delete from idw_sy_workflow_error
                  where     workflow_id = l_process_data.workflow_id
                        and state_id = l_process_data.state_id
                        and object_id = c.object_id;

           rco_helper.log(l_process || 'выполнено system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, l_procedure);
           --выход, если превышено количество обработанных объектов в пачке
            exit when l_cnt >= l_batch_size;
         exception
            when others
            then
               null;
               idwh2.pkg_eor_aux.save_error (
                  l_id,
                  l_process_data.workflow_id,
                  l_process_data.state_id,
                  sqlcode,
                  sqlerrm,
                  dbms_utility.format_error_backtrace);
               rollback to pr_eor_pdl_load;
               l_err_cnt := l_err_cnt + 1;
         end;
      end loop;

      commit;
      rco_benchmark.benchmark_stop (l_process);
      rco_helper.log (l_process || ' items processed ' || l_cnt, l_procedure);
   end process_batch;
begin
   -- читаем настройки процесса
   select *
     into l_process_data
     from idw_rco_process_state
    where process_alias = l_process;

   l_batch_size := l_process_data.batch_size;

   rco_helper.log ('start of ' || l_process, l_procedure);

   -- проверяем, не много ли накопилось ошибок

   select count (1)
     into l_err_cnt
     from idw_sy_workflow_error
    where     workflow_id = l_process_data.workflow_id
          and state_id = l_process_data.state_id;

   if     l_err_cnt >= l_process_data.max_error
      and pkg_rco_process.can_run (l_process) <> 2
   then
      --===========================================================================================
      -- Если накопилось много ошибок, то выводим сообщение в диспетчере!!!
      --===========================================================================================
           idwh2.pkg_log.write_error(
                p_id_process_log => p_id_process_log,
                p_message        => 'Накопилось много ошибок!!! Запустите процесс "'||l_process||'" в режиме обработки ошибок!' ,
                p_call_stack     => 'Накопилось много ошибок ('||l_err_cnt||')!!! В таблице IDWH2.IDW_RCO_PROCESS_STATE для процесса "'||l_process||'" максимальное кол-во ошибок '||l_process_data.max_error||'!',
                p_comments       => 'Ошибки данных');
      rco_helper.log (l_process || ' too many errors! exiting', l_procedure);
      return;
   end if;

  <<next_portion>>
   null;

   -- проверяем, не помечен ли
   if not pkg_rco_process.can_run (l_process) in (1, 2)
   then
      rco_helper.log (l_process || ' marked to stop by user! exiting',
                      l_procedure);
      return;
   end if;

   if pkg_rco_process.can_run (l_process) = 2
   then
      l_error_sign := '1';
      l_batch_size := 1;
      rco_helper.log (l_process || ' error processing mode', l_procedure);
   else
      l_error_sign := '0';
      l_batch_size := l_process_data.batch_size;
      rco_helper.log (l_process || ' normal processing mode', l_procedure);
   end if;

   -- обрабатываем порцию
   l_start_date := sysdate;

   process_batch;

   l_end_date := sysdate;
   idwh2.process_info_log_wm (p_id_process_log   => p_id_process_log,
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
      rco_helper.log (l_process || ' no more items! exiting', l_procedure);
      return;
   end if;

   select count (1)
     into l_err_cnt
     from idw_sy_workflow_error
    where     workflow_id = l_process_data.workflow_id
          and state_id = l_process_data.state_id;

   -- накопилось много ошибок, выходим
   if l_err_cnt >= l_process_data.max_error
   then
      --===========================================================================================
      -- Если накопилось много ошибок, то выводим сообщение в диспетчере!!!
      --===========================================================================================
           idwh2.pkg_log.write_error(
                p_id_process_log => p_id_process_log,
                p_message        => 'Накопилось много ошибок!!! Запустите процесс "'||l_process||'" в режиме обработки ошибок!' ,
                p_call_stack     => 'Накопилось много ошибок ('||l_err_cnt||')!!! В таблице IDWH2.IDW_RCO_PROCESS_STATE для процесса "'||l_process||'" максимальное кол-во ошибок '||l_process_data.max_error||'!',
                p_comments       => 'Ошибки данных');
      rco_helper.log (l_process || ' too many errors! exiting', l_procedure);
      return;
   end if;

   goto next_portion;
end pr_eor_pdl_load;
