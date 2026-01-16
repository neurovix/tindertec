insert into degrees (name) values
('Ingenieria en Sistemas Computacionales'),
('Ingenieria Electrica'),
('Ingenieria Electronica'),
('Ingenieria Industrial'),
('Ingenieria Mecanica'),
('Ingenieria Mecatronica'),
('Ingenieria Materiales'),
('Ingenieria en Gestion Empresarial'),
('Otra')
on conflict do nothing;

insert into life_habits (name) values
('Siempre escuchando musica'),
('Gym'),
('Amigable'),
('Coffe lover'),
('Extrovertido'),
('Procrastinador'),
('Organizado'),
('Team nocturno'),
('Introvertido'),
('Fan del descanso'),
('Team madrugador'),
('Foraneo'),
('Todo el dia en el tec'),
('Me quedo a actividades'),
('Ingeniero'),
('Busco ride'),
('Recursando'),
('Sin dinero'),
('Entro a todas las clases')
on conflict do nothing;

insert into genders (name) values
('Hombre'),
('Mujer'),
('Prefiero no decirlo')
on conflict do nothing;

insert into interests (name) values
('Hombres'),
('Mujeres'),
('Todxs')
on conflict do nothing;

insert into looking_for (name) values
('Relacion seria'),
('Diversion/Corto plazo'),
('Hacer tarea juntos'),
('Contactos/Negocios'),
('Amigos'),
('Lo sigo pensando')
on conflict do nothing;
