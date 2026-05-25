import { db } from "@workspace/db";
import {
  categoriesTable,
  locationsTable,
  eventsTable,
  schedulesTable,
} from "@workspace/db";

async function seed() {
  console.log("Seeding database...");

  // Categories
  const categories = await db
    .insert(categoriesTable)
    .values([
      { name: "Conferencia", description: "Conferencias y charlas magistrales" },
      { name: "Seminario", description: "Seminarios académicos especializados" },
      { name: "Taller", description: "Talleres prácticos y workshops" },
      { name: "Simposio", description: "Simposios y encuentros académicos" },
      { name: "Congreso", description: "Congresos y jornadas académicas" },
    ])
    .returning()
    .onConflictDoNothing();

  console.log(`Inserted ${categories.length} categories`);

  // Locations
  const locations = await db
    .insert(locationsTable)
    .values([
      { name: "Aula Magna", address: "Edificio Central, Campus Principal", capacity: 500 },
      { name: "Sala de Conferencias A", address: "Facultad de Ingeniería, Piso 2", capacity: 120 },
      { name: "Laboratorio de Innovación", address: "Centro de Tecnología, Piso 1", capacity: 40 },
      { name: "Auditorio Norte", address: "Sede Norte, Bloque B", capacity: 250 },
    ])
    .returning()
    .onConflictDoNothing();

  console.log(`Inserted ${locations.length} locations`);

  if (categories.length > 0 && locations.length > 0) {
    const now = new Date();
    const nextWeek = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    const nextMonth = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);
    const yesterday = new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000);

    const events = await db
      .insert(eventsTable)
      .values([
        {
          title: "Inteligencia Artificial y el Futuro de la Educación",
          description: "Una exploración profunda sobre cómo la IA está transformando los métodos de enseñanza y aprendizaje en las universidades modernas.",
          startDate: nextWeek,
          endDate: new Date(nextWeek.getTime() + 3 * 60 * 60 * 1000),
          categoryId: categories[0]?.id,
          locationId: locations[0]?.id,
          maxAttendees: 400,
          status: "upcoming",
        },
        {
          title: "Taller: Desarrollo Web con Flutter",
          description: "Aprende a crear aplicaciones web modernas utilizando Flutter y Dart. Taller completamente práctico.",
          startDate: nextWeek,
          endDate: new Date(nextWeek.getTime() + 4 * 60 * 60 * 1000),
          categoryId: categories[2]?.id,
          locationId: locations[2]?.id,
          maxAttendees: 35,
          status: "upcoming",
        },
        {
          title: "Congreso Anual de Ingeniería de Software",
          description: "El evento más importante de la facultad. Presentación de proyectos, papers y networking con profesionales del sector.",
          startDate: nextMonth,
          endDate: new Date(nextMonth.getTime() + 8 * 60 * 60 * 1000),
          categoryId: categories[4]?.id,
          locationId: locations[0]?.id,
          maxAttendees: 500,
          status: "upcoming",
        },
        {
          title: "Seminario: Ética en la Investigación Científica",
          description: "Discusión sobre principios éticos fundamentales en la investigación, integridad académica y buenas prácticas científicas.",
          startDate: yesterday,
          endDate: new Date(yesterday.getTime() + 2 * 60 * 60 * 1000),
          categoryId: categories[1]?.id,
          locationId: locations[1]?.id,
          maxAttendees: 100,
          status: "finished",
        },
      ])
      .returning()
      .onConflictDoNothing();

    console.log(`Inserted ${events.length} events`);

    if (events[0]) {
      await db.insert(schedulesTable).values([
        {
          eventId: events[0].id,
          title: "Keynote: Estado actual de la IA en educación",
          speaker: "Dra. María González",
          startTime: events[0].startDate,
          endTime: new Date(events[0].startDate.getTime() + 60 * 60 * 1000),
          room: "Sala Principal",
        },
        {
          eventId: events[0].id,
          title: "Panel: Herramientas de IA para docentes",
          speaker: "Prof. Carlos Martínez",
          startTime: new Date(events[0].startDate.getTime() + 60 * 60 * 1000),
          endTime: new Date(events[0].startDate.getTime() + 2 * 60 * 60 * 1000),
          room: "Sala Principal",
        },
        {
          eventId: events[0].id,
          title: "Cierre y preguntas",
          speaker: "Moderadora: Dra. Ana Pérez",
          startTime: new Date(events[0].startDate.getTime() + 2 * 60 * 60 * 1000),
          endTime: new Date(events[0].startDate.getTime() + 3 * 60 * 60 * 1000),
          room: "Sala Principal",
        },
      ]).onConflictDoNothing();
      console.log("Inserted schedules for first event");
    }
  }

  console.log("Seed complete!");
  process.exit(0);
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});
