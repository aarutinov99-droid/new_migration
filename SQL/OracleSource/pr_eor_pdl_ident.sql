CREATE OR REPLACE procedure IDWH2.pr_eor_pdl_ident (p_id_process_log number)
as
   /* Регламентный процесс идентификация  публичных должностных лиц в спецреестре с субъектами ЕОР */
   l_process                  varchar2 (100) := 'PR_EOR_PDL_IDENT';
   l_procedure                varchar2 (100) := 'pr_eor_pdl_ident';
   l_sr_type_id               number := 145;
   l_source_id                number := 2070;

   l_process_data             idw_rco_process_state%rowtype;
   l_batch_size               number;
   l_cnt                      number := 0;
   l_err_cnt                  number := 0;
   l_error_sign               varchar2 (1 byte) := '0';
   l_id                       varchar2 (100);
   l_start_date               date;
   l_end_date                 date;
   l_eor_count                number;
   l_sr_subject_count         number;
   l_sr_subject_id            number;
   l_etalon_registry_id       number;
   l_nr                       char (1);
   l_find_id                  number;
   l_f_res                    number;
   l_eor_subject_mention_id   number;
   l_is_rfl                   number;
   l_rfl_attr   idw_mr_rfl_attr_src % rowtype;
   l_ifl_attr   idw_mr_ifl_attr_src % rowtype;
	 l_sr_event_id              number;


   procedure find_rfl_candidate (p_full_name        varchar2,
                                 p_birth_date       date,
                                 p_find_id      out number)
   as
      l_max_cnt   constant number := 1000;
   begin
      p_find_id := seq_find_candidate.nextval;

      -- чистим временную таблицу
      delete from tmp_eor_ident_candidate;

      -- по ФИО и дате рождения (точное сопадение)
      merge into tmp_eor_ident_candidate ic
           using (select m.etalon_registry_id,
                         m.eor_h_id,
                         count (1) over (partition by 1) cnt
                    from    idwh2.idw_mr_master m
                         inner join
                            idwh2.idwh2_etalon_flrn f
                         on f.etalon_registry_id = m.etalon_registry_id
                   where     f.birth_date = p_birth_date
                         and f.full_name = p_full_name
                         and m.deleted_sign = '0') res
              on (    ic.etalon_registry_id = res.etalon_registry_id
                  and ic.find_candidate_id = p_find_id)
      when not matched
      then
         insert     (ic.find_candidate_id,
                     ic.etalon_registry_id,
                     ic.eor_h_id,
                     ic.weight)
             values (p_find_id,
                     res.etalon_registry_id,
                     res.eor_h_id,
                     1 / (1 + log (10, res.cnt)))
              where res.cnt <= l_max_cnt
      when matched
      then
         update set ic.weight = ic.weight + 1 / (1 + log (10, res.cnt))
                 where res.cnt <= l_max_cnt;

      -- по ФИО (точное сопадение)
      merge into tmp_eor_ident_candidate ic
           using (select m.etalon_registry_id,
                         m.eor_h_id,
                         count (1) over (partition by 1) cnt
                    from    idwh2.idw_mr_master m
                         inner join
                            idwh2.idwh2_etalon_flrn f
                         on f.etalon_registry_id = m.etalon_registry_id
                   where f.full_name = p_full_name and m.deleted_sign = '0') res
              on (    ic.etalon_registry_id = res.etalon_registry_id
                  and ic.find_candidate_id = p_find_id)
      when not matched
      then
         insert     (ic.find_candidate_id,
                     ic.etalon_registry_id,
                     ic.eor_h_id,
                     ic.weight)
             values (p_find_id,
                     res.etalon_registry_id,
                     res.eor_h_id,
                     1 / (1 + log (10, res.cnt)))
              where res.cnt <= l_max_cnt
      when matched
      then
         update set ic.weight = ic.weight + 1 / (1 + log (10, res.cnt))
                 where res.cnt <= l_max_cnt;
   exception
      when others
      then
         raise;
   end find_rfl_candidate;


   procedure find_nr_fl_candidate (p_full_name        varchar2,
                                   p_birth_date       date,
                                   p_find_id      out number)
   as
      l_max_cnt   constant number := 1000;
   begin
      p_find_id := seq_find_candidate.nextval;

      -- чистим временную таблицу
      delete from tmp_eor_ident_candidate;

      -- по ФИО и дате рождения (точное сопадение)
      merge into tmp_eor_ident_candidate ic
           using (select m.etalon_registry_id,
                         m.eor_h_id,
                         count (1) over (partition by 1) cnt
                    from    idwh2.idw_mr_master m
                         inner join
                            idwh2.idwh2_etalon_nr_fl f
                         on f.etalon_registry_id = m.etalon_registry_id
                   where     f.birth_date = p_birth_date
                         and f.full_name = p_full_name
                         and m.deleted_sign = '0') res
              on (    ic.etalon_registry_id = res.etalon_registry_id
                  and ic.find_candidate_id = p_find_id)
      when not matched
      then
         insert     (ic.find_candidate_id,
                     ic.etalon_registry_id,
                     ic.eor_h_id,
                     ic.weight)
             values (p_find_id,
                     res.etalon_registry_id,
                     res.eor_h_id,
                     1 / (1 + log (10, res.cnt)))
              where res.cnt <= l_max_cnt
      when matched
      then
         update set ic.weight = ic.weight + 1 / (1 + log (10, res.cnt))
                 where res.cnt <= l_max_cnt;

      -- по ФИО (точное сопадение)
      merge into tmp_eor_ident_candidate ic
           using (select m.etalon_registry_id,
                         m.eor_h_id,
                         count (1) over (partition by 1) cnt
                    from    idwh2.idw_mr_master m
                         inner join
                            idwh2.idwh2_etalon_nr_fl f
                         on f.etalon_registry_id = m.etalon_registry_id
                   where f.full_name = p_full_name and m.deleted_sign = '0') res
              on (    ic.etalon_registry_id = res.etalon_registry_id
                  and ic.find_candidate_id = p_find_id)
      when not matched
      then
         insert     (ic.find_candidate_id,
                     ic.etalon_registry_id,
                     ic.eor_h_id,
                     ic.weight)
             values (p_find_id,
                     res.etalon_registry_id,
                     res.eor_h_id,
                     1 / (1 + log (10, res.cnt)))
              where res.cnt <= l_max_cnt
      when matched
      then
         update set ic.weight = ic.weight + 1 / (1 + log (10, res.cnt))
                 where res.cnt <= l_max_cnt;
   exception
      when others
      then
         raise;
   end find_nr_fl_candidate;


   procedure process_batch
   as
   begin
      rco_benchmark.benchmark_start (l_process);
      l_cnt := 0;
      l_err_cnt := 0;

      for c
         in (select p.date_birthday,
                    p.full_name,
                    p.sr_subject_id,
                    p.system_id,
                    p.countries,
                    p.rowid rid,
                    p.update_date
               from    eor.sr_subject_pdl p
                    left join
                       eor.sr_subject s
                    on s.sr_subject_id = p.sr_subject_id
              where     is_eor_ident_process = 0
                    and s.etalon_registry_id is null-- and s.etalon_registry_id > 0
                    and rownum <= l_process_data.batch_size)
      loop
         savepoint pr_eor_pdl_ident;

         begin
            l_id := to_char (c.sr_subject_id);
            rco_helper.log(l_process || 'загрузка system_id = ' || c.system_id || '  l_id = '|| l_id, l_procedure);

            l_etalon_registry_id := null;
            l_sr_subject_id := null;

            --Нужно определить, был ли ранее в спецреестре
            --если  был и не смогли идентифицировать, создаем упоминание
            --упоминание в очередь не ставим
            select count (1)
              into l_sr_subject_count
              from eor.sr_subject s
             where     s.sr_subject_id = c.sr_subject_id
                   and s.sr_type_id = l_sr_type_id;

            if l_sr_subject_count > 0
            then
               select s.sr_subject_id
                 into l_sr_subject_id
                 from eor.sr_subject s
                where     s.sr_subject_id = c.sr_subject_id
                      and s.sr_type_id = l_sr_type_id;
            end if;

            if    upper (c.countries) like '%РОССИЯ%'
               or c.countries is null
            then
               l_is_rfl := 1;
            else
               l_is_rfl := 0;
            end if;

            --=====================================================================
            --Поиск в ЕОР
            --ФИО + ДатаРождения, Эталонная запись, только если карточка одна
            --ФИО + ДатаРождения, Неэталонная запись, только если карточка одна
            --ФИО, Эталонная запись, только если карточка одна
            --ФИО, Эталонная запись, только если карточка одна
            --=====================================================================

            -- если РФЛ - поиск по имени и дате рождения
            -- если записей найдено больше одной, выбирается первая запись из списка отсортированного по:  Признак эталонной записи и Дата версии записи
            -- от большей к меньшей
            if    (l_is_rfl = 1 and c.full_name is not null)

            then
               find_rfl_candidate (c.full_name, c.date_birthday, l_find_id);

               --ФИО + ДатаРождения, Эталонная запись, только если карточка одна
               if     l_etalon_registry_id is null
                  and c.full_name is not null
                  and c.date_birthday is not null
               then
                  begin
                     select etalon_registry_id
                       into l_etalon_registry_id
                       from (select max (m.etalon_registry_id)
                                       etalon_registry_id,
                                    count (1) c
                               from (select m.etalon_registry_id,
                                            mm.etalon_sign,
                                            eor_h_date
                                       from tmp_eor_ident_candidate t
                                            join idwh2.idwh2_etalon_flrn m
                                               on t.etalon_registry_id =
                                                     m.etalon_registry_id
                                            join idwh2.idw_mr_master mm
                                               on m.etalon_registry_id =
                                                     mm.etalon_registry_id
                                      where     m.full_name =
                                                   trim (upper (c.full_name))
                                            and m.birth_date =
                                                   c.date_birthday
                                            and mm.etalon_sign = '1') m)
                      where c = 1;
                  exception
                     when no_data_found
                     then
                        null;
                  end;
               end if;

               --ФИО + ДатаРождения, Неэталонная запись, только если карточка одна
               if     l_etalon_registry_id is null
                  and c.full_name is not null
                  and c.date_birthday is not null
               then
                  begin
                     select etalon_registry_id
                       into l_etalon_registry_id
                       from (select max (m.etalon_registry_id)
                                       etalon_registry_id,
                                    count (1) c
                               from (select m.etalon_registry_id,
                                            mm.etalon_sign,
                                            eor_h_date
                                       from tmp_eor_ident_candidate t
                                            join idwh2.idwh2_etalon_flrn m
                                               on t.etalon_registry_id =
                                                     m.etalon_registry_id
                                            join idwh2.idw_mr_master mm
                                               on m.etalon_registry_id =
                                                     mm.etalon_registry_id
                                      where     m.full_name =
                                                   trim (upper (c.full_name))
                                            and m.birth_date =
                                                   c.date_birthday
                                            and mm.etalon_sign = '0') m)
                      where c = 1;
                  exception
                     when no_data_found
                     then
                        null;
                  end;
               end if;

               --ФИО, Эталонная запись, только если карточка одна
               if l_etalon_registry_id is null and c.full_name is not null
               then
                  begin
                     select etalon_registry_id
                       into l_etalon_registry_id
                       from (select max (m.etalon_registry_id)
                                       etalon_registry_id,
                                    count (1) c
                               from (select m.etalon_registry_id,
                                            mm.etalon_sign,
                                            eor_h_date
                                       from tmp_eor_ident_candidate t
                                            join idwh2.idwh2_etalon_flrn m
                                               on t.etalon_registry_id =
                                                     m.etalon_registry_id
                                            join idwh2.idw_mr_master mm
                                               on m.etalon_registry_id =
                                                     mm.etalon_registry_id
                                      where     m.full_name =
                                                   trim (upper (c.full_name))
                                            and mm.etalon_sign = '1') m)
                      where c = 1;
                  exception
                     when no_data_found
                     then
                        null;
                  end;
               end if;

               --ФИО, Неэталонная запись, только если карточка одна
               if l_etalon_registry_id is null and c.full_name is not null
               then
                  begin
                     select etalon_registry_id
                       into l_etalon_registry_id
                       from (select max (m.etalon_registry_id)
                                       etalon_registry_id,
                                    count (1) c
                               from (select m.etalon_registry_id,
                                            mm.etalon_sign,
                                            eor_h_date
                                       from tmp_eor_ident_candidate t
                                            join idwh2.idwh2_etalon_flrn m
                                               on t.etalon_registry_id =
                                                     m.etalon_registry_id
                                            join idwh2.idw_mr_master mm
                                               on m.etalon_registry_id =
                                                     mm.etalon_registry_id
                                      where     m.full_name =
                                                   trim (upper (c.full_name))
                                            and mm.etalon_sign = '0') m)
                      where c = 1;
                  exception
                     when no_data_found
                     then
                        null;
                  end;
               end if;
            end if;

            -- если ИФЛ ищем по имени и дате рождения
            -- если записей найдено больше одной, выбирается первая запись из списка отсортированного по:  Признак эталонной записи и Дата версии записи
            -- от большей к меньшей
            if l_is_rfl = 0 and c.full_name is not null
            then
               find_nr_fl_candidate (c.full_name, c.date_birthday, l_find_id);

               --ФИО + ДатаРождения, Эталонная запись, только если карточка одна
               if     l_etalon_registry_id is null
                  and c.full_name is not null
                  and c.date_birthday is not null
               then
                  begin
                     select etalon_registry_id
                       into l_etalon_registry_id
                       from (select max (m.etalon_registry_id)
                                       etalon_registry_id,
                                    count (1) c
                               from (select m.etalon_registry_id,
                                            mm.etalon_sign,
                                            eor_h_date
                                       from tmp_eor_ident_candidate t
                                            join idwh2.idwh2_etalon_nr_fl m
                                               on t.etalon_registry_id =
                                                     m.etalon_registry_id
                                            join idwh2.idw_mr_master mm
                                               on m.etalon_registry_id =
                                                     mm.etalon_registry_id
                                      where     m.full_name =
                                                   trim (upper (c.full_name))
                                            and m.birth_date =
                                                   c.date_birthday
                                            and mm.etalon_sign = '1') m)
                      where c = 1;
                  exception
                     when no_data_found
                     then
                        null;
                  end;
               end if;

               --ФИО + ДатаРождения, Неэталонная запись, только если карточка одна
               if     l_etalon_registry_id is null
                  and c.full_name is not null
                  and c.date_birthday is not null
               then
                  begin
                     select etalon_registry_id
                       into l_etalon_registry_id
                       from (select max (m.etalon_registry_id)
                                       etalon_registry_id,
                                    count (1) c
                               from (select m.etalon_registry_id,
                                            mm.etalon_sign,
                                            eor_h_date
                                       from tmp_eor_ident_candidate t
                                            join idwh2.idwh2_etalon_nr_fl m
                                               on t.etalon_registry_id =
                                                     m.etalon_registry_id
                                            join idwh2.idw_mr_master mm
                                               on m.etalon_registry_id =
                                                     mm.etalon_registry_id
                                      where     m.full_name =
                                                   trim (upper (c.full_name))
                                            and m.birth_date =
                                                   c.date_birthday
                                            and mm.etalon_sign = '0') m)
                      where c = 1;
                  exception
                     when no_data_found
                     then
                        null;
                  end;
               end if;

               --ФИО, Эталонная запись, только если карточка одна
               if l_etalon_registry_id is null and c.full_name is not null
               then
                  begin
                     select etalon_registry_id
                       into l_etalon_registry_id
                       from (select max (m.etalon_registry_id)
                                       etalon_registry_id,
                                    count (1) c
                               from (select m.etalon_registry_id,
                                            mm.etalon_sign,
                                            eor_h_date
                                       from tmp_eor_ident_candidate t
                                            join idwh2.idwh2_etalon_nr_fl m
                                               on t.etalon_registry_id =
                                                     m.etalon_registry_id
                                            join idwh2.idw_mr_master mm
                                               on m.etalon_registry_id =
                                                     mm.etalon_registry_id
                                      where     m.full_name =
                                                   trim (upper (c.full_name))
                                            and mm.etalon_sign = '1') m)
                      where c = 1;
                  exception
                     when no_data_found
                     then
                        null;
                  end;
               end if;

               --ФИО, Неэталонная запись, только если карточка одна
               if l_etalon_registry_id is null and c.full_name is not null
               then
                  begin
                     select etalon_registry_id
                       into l_etalon_registry_id
                       from (select max (m.etalon_registry_id)
                                       etalon_registry_id,
                                    count (1) c
                               from (select m.etalon_registry_id,
                                            mm.etalon_sign,
                                            eor_h_date
                                       from tmp_eor_ident_candidate t
                                            join idwh2.idwh2_etalon_nr_fl m
                                               on t.etalon_registry_id =
                                                     m.etalon_registry_id
                                            join idwh2.idw_mr_master mm
                                               on m.etalon_registry_id =
                                                     mm.etalon_registry_id
                                      where     m.full_name =
                                                   trim (upper (c.full_name))
                                            and mm.etalon_sign = '0') m)
                      where c = 1;
                  exception
                     when no_data_found
                     then
                        null;
                  end;
               end if;
            end if;

            --=====================================================================
            -- ИДЕНТИФИЦИРОВАН
            --=====================================================================
            --идентифицировали ранее созданный - обновим ИД ЕОР
            if l_etalon_registry_id is not null and l_sr_subject_id > 0
            then
             	--переместить в историю
           		l_sr_event_id := idwh2.sr_common_pkg.sr_event_add( 101, l_sr_type_id, c.sr_subject_id, l_etalon_registry_id, null, '0', user);
           		-- сохранение истории
           		idwh2.sr_common_pkg.sr_subject_save_h(c.sr_subject_id);
              update eor.sr_subject s
                  set s.etalon_registry_id = l_etalon_registry_id, sr_event_id = l_sr_event_id
               where     s.sr_subject_id = c.sr_subject_id
                      and s.sr_type_id = l_sr_type_id;
            elsif l_etalon_registry_id is not null and l_sr_subject_id is null
            then
               l_sr_event_id := idwh2.sr_common_pkg.sr_event_add( 100, l_sr_type_id, c.sr_subject_id, l_etalon_registry_id, null, '0', user);
               --Вставка субъекта спецреестра
               insert into eor.sr_subject (sr_subject_id,
                                           etalon_registry_id,
                                           incl_first_date,
                                           incl_date,
                                           incl_reason,
                                           excl_reason,
                                           deleted_sign,
                                           sr_type_id,
                                           actual_sign,
                                           checked_sign, sr_event_id)
                    values (c.sr_subject_id,
                            l_etalon_registry_id,
                            sysdate,
                            sysdate,
                            'X-Complince',
                            null,
                            '0',
                            l_sr_type_id,
                            '1',
                            '0', l_sr_event_id);
            end if;

            --=====================================================================
            -- СОЗДАЕМ УПОМИНАНИЕ
            --=====================================================================
            l_eor_subject_mention_id := null;

            if l_etalon_registry_id is null
            then

                -- поиск наличия упоменания с одинаковым SOURSE_ID и external_h_id
                begin
                    select t.eor_subject_mention_id into l_eor_subject_mention_id
                    from idwh2.idw_mr_subject_mention t
                    where source_id = l_source_id and
                          external_h_id = c.rid;
                exception
                    when no_data_found then
                        null;
                end;

               if l_is_rfl = 1 and l_eor_subject_mention_id is  null
               then
                  l_rfl_attr.full_name := c.full_name;
                  l_rfl_attr.birth_date := c.date_birthday;
                  l_eor_subject_mention_id :=
                     pkg_eor_api.add_subj_rfl_mention (
                        p_source_id          => l_source_id,
                        p_source_etalon_id   => 0,
                        p_external_id        => c.system_id,
                        p_external_h_id      => c.rid,
                        p_actual_date        => c.update_date,
                        p_attributes         => l_rfl_attr,
                        p_priority           => 10,
                        p_in_queue           => 0);
               end if;

               if l_is_rfl = 1 and l_eor_subject_mention_id is null
               then
                  l_ifl_attr.full_name := c.full_name;
                  l_ifl_attr.birth_date := c.date_birthday;
                  l_eor_subject_mention_id :=
                     pkg_eor_api.add_subj_ifl_mention (
                        p_source_id          => l_source_id,
                        p_source_etalon_id   => 0,
                        p_external_id        => c.system_id,
                        p_external_h_id      => c.rid,
                        p_actual_date        => c.update_date,
                        p_attributes         => l_ifl_attr,
                        p_priority           => 10,
                        p_in_queue           => 0);
               end if;

                  -- поставить в очередь на распознавание
                            --
             if l_sr_subject_id is null and l_eor_subject_mention_id is not null
               then

                  l_sr_event_id := idwh2.sr_common_pkg.sr_event_add( 100, l_sr_type_id, c.sr_subject_id, l_etalon_registry_id, null, '0', user);
                 --Вставка субъекта спецреестра
                  insert into eor.sr_subject (sr_subject_id,
                                              eor_subject_mention_id,
                                              incl_first_date,
                                              incl_date,
                                              incl_reason,
                                              excl_reason,
                                              deleted_sign,
                                              sr_type_id,
                                              actual_sign,
                                              checked_sign,
										                          sr_event_id)
                       values (c.sr_subject_id,
                               l_eor_subject_mention_id,
                               sysdate,
                               sysdate,
                               'X-Complince',
                               null,
                               '0',
                               l_sr_type_id,
                               '1',
                               '0', l_sr_event_id);
               else
            		-- сохранение истории
            		idwh2.sr_common_pkg.sr_subject_save_h(c.sr_subject_id);
           		  l_sr_event_id := idwh2.sr_common_pkg.sr_event_add( 101, l_sr_type_id, c.sr_subject_id, l_etalon_registry_id, null, '0', user);

                update eor.sr_subject s
	                set s.eor_subject_mention_id = l_eor_subject_mention_id,
									     s.sr_event_id = l_sr_event_id, s.deleted_sign = '0',
												s.actual_sign = '1', s.checked_sign = '4',
													s.excl_date = null, s.excl_reason = null
                   where     s.sr_subject_id = c.sr_subject_id
                         and s.sr_type_id = l_sr_type_id;
               end if;
            end if;


            delete from idw_sy_workflow_error
                  where     workflow_id = l_process_data.workflow_id
                        and state_id = l_process_data.state_id
                        and object_id = l_id;

            l_cnt := l_cnt + 1;

            update eor.sr_subject_pdl p
               set p.is_eor_ident_process = 1
             where p.sr_subject_id = c.sr_subject_id;

            rco_helper.log(l_process || 'Выполнено system_id = ' || c.system_id || '  l_id = '|| l_id, l_procedure);

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
               rollback to pr_eor_pdl_ident;
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
end pr_eor_pdl_ident;
