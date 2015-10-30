// Copyright 2015 Las Venturas Playground. All rights reserved.
// Use of this source code is governed by the MIT license, a copy of which can
// be found in the LICENSE file.

let RaceImporter = require('features/races/race_importer.js');

describe('RaceImporter', it => {
  it('should require and validate the name', assert => {
    let importName = data => {
      let importer = RaceImporter.fromDataForTests(data);
      importer.importName();
      return importer.race;
    };

    assert.throws(() => importName({}));
    assert.throws(() => importName({ name: 42 }));
    assert.throws(() => importName({ name: '' }));

    let race = importName({ name: 'MyRace' });
    assert.equal(race.name, 'My Race');
  });

  it('should require and validate spawn positions', assert => {
    let importSpawnPositions = data => {
      let importer = RaceImporter.fromDataForTests(data);
      importer.importSpawnPositions();
      return importer.race;
    });

    let position = [ 0, 0, 0 ];
    let rotation = 180;
    let vehicle = { model: 411 };

    assert.throws(() => importSpawnPositions({}));
    assert.throws(() => importSpawnPositions({ spawn_positions: 42 }));
    assert.throws(() => importSpawnPositions({ spawn_positions: [] }));
    assert.throws(() => importSpawnPositions({ spawn_positions: [ 42 ] }));
    assert.throws(() => importSpawnPositions(
        { spawn_positions: [ { position: false, rotation, vehicle } ] }));

    assert.throws(() => importSpawnPositions(
        { spawn_positions: [ { position, rotation: false, vehicle } ] }));

    assert.throws(() => importSpawnPositions(
        { spawn_positions: [ { position, rotation, vehicle: false } ] }));

    assert.throws(() => importSpawnPositions(
        { spawn_positions: [ { position, rotation, vehicle: { model: 411, colors: 42 } } ] }));

    assert.throws(() => importSpawnPositions(
        { spawn_positions: [ { position, rotation, vehicle: { model: 411, nos: 42 } } ] }));

    let race = importSpawnPositions({
      spawn_positions: [
        { position, rotation, vehicle },
        { position, rotation, vehicle }
      ]
    });

    assert.equal(race.spawnPositions.length, 2);
  });

  it('should require and validate checkpoints', assert => {
    let importCheckpoints = data => {
      let importer = RaceImporter.fromDataForTests(data);
      importer.importCheckpoints();
      return importer.race;
    };

    assert.throws(() => importCheckpoints({}));
    assert.throws(() => importCheckpoints({ checkpoints: 42 }));
    assert.throws(() => importCheckpoints({ checkpoints: [] }));

    assert.throws(() => importCheckpoints({ checkpoints: [ { position: 42 } ] }));
    assert.throws(() => importCheckpoints({ checkpoints: [ { position: [ 42 ] } ] }));
    assert.throws(() => importCheckpoints({ checkpoints: [ { position: [ 42, 42 ] } ] });
    assert.throws(() => importCheckpoints({ checkpoints: [ { position: [ 0, 0, 0 ], size: -100 } ] }));
    assert.throws(() => importCheckpoints({ checkpoints: [ { position: [ 0, 0, 0 ], size: 9999 } ] }));

    let race = importCheckpoints({
      checkpoints: [
        { position: [ 42, 42, 42 ] },
        { position: [ 42, 42, 42 ], size: 10 }
      ]
    });

    assert.equal(race.checkpoints.length, 2);
  });

  it('should validate the number of laps', assert => {
    let importLaps = data => {
      let importer = RaceImporter.fromDataForTests(data);
      importer.importLaps();
      return importer.race;
    };

    assert.equal(importLaps({}).laps, 1);  // this field is optional
    assert.equal(importLaps({ laps: 3 }).laps, 3);

    assert.throws(() => importLaps({ laps: true }));
    assert.throws(() => importLaps({ laps: -1 }));
    assert.throws(() => importLaps({ laps: 9999 }));
  });

  it('should validate and apply the environment', assert => {
    let importEnvironment = data => {
      let importer = RaceImporter.fromDataForTests(data);
      importer.importEnvironment();
      return importer.race;
    };

    let defaultValues = importEnvironment({});
    assert.isNotNull(defaultValues.weather);
    assert.isNumber(defaultValues.weather);

    assert.isNotNull(defaultValues.time);
    assert.isArray(defaultValues.time);
    assert.equal(defaultValues.time.length, 2);

    assert.isNotNull(defaultValues.interior);
    assert.isNumber(defaultValues.interior);

    assert.throws(() => importEnvironment({ environment: false }));
    assert.throws(() => importEnvironment({ environment: [] }));
    assert.throws(() => importEnvironment({ environment: { weather: 'sunny' }}));
    assert.throws(() => importEnvironment({ environment: { time: 42 }}));
    assert.throws(() => importEnvironment({ environment: { time: 'midnight' }}));
    assert.throws(() => importEnvironment({ environment: { time: [ 0 ] }}));
    assert.throws(() => importEnvironment({ environment: { interior: 'inside' }}));
    assert.throws(() => importEnvironment({ environment: { interior: -1 }}));
    assert.throws(() => importEnvironment({ environment: { interior: 99 }}));

    let customValues = importEnvironment({
      environment: {
        weather: 42,
        time: [18, 42],
        interior: 7
      }
    });

    assert.equal(customValues.weather, 42);
    assert.deepEqual(customValues.time, [18, 42]);
    assert.equal(customValues.interior, 7);
  });

  it('should validate and apply a time limit', assert => {
    let importTimeLimit = data => {
      let importer = RaceImporter.fromDataForTests(data);
      importer.importTimeLimit();
      return importer.race;
    };

    assert.equal(importTimeLimit({}).timeLimit, 0);

    assert.throws(() => importTimeLimit({ time_limit: 'nevah' }));
    assert.throws(() => importTimeLimit({ time_limit: -42 }));
    assert.throws(() => importTimeLimit({ time_limit: 99999 }));

    assert.equal(importTimeLimit({ time_limit: 300 }).timeLimit, 300);
  });

  it('should validate and apply the challenge desk', assert => {
    let importChallengeDesk = data => {
      let importer = RaceImporter.fromDataForTests(data);
      importer.importChallengeDesk();
      return importer.race;
    };

    assert.isNull(importChallengeDesk({}).challengeDesk);

    assert.throws(() => importChallengeDesk({ challenge_desk: false }));
    assert.throws(() => importChallengeDesk({ challenge_desk: [] }));
    assert.throws(() => importChallengeDesk(
        { challenge_desk: { /** actor_model **/, position: true, rotation: true } }));
    assert.throws(() => importChallengeDesk(
        { challenge_desk: { actor_model: true, /** position **/, rotation: true } }));
    assert.throws(() => importChallengeDesk(
        { challenge_desk: { actor_model: true, position: true, /** rotation **/ } }));

    let actor_model = 121;
    let position = [0, 0, 0];
    let rotation = 180;

    assert.throws(() => importChallengeDesk(
        { challenge_desk: { actor_model: 'some_guy', position, rotation } }));
    assert.throws(() => importChallengeDesk(
        { challenge_desk: { actor_model, position: [ 42 ], rotation } }));
    assert.throws(() => importChallengeDesk(
        { challenge_desk: { actor_model, position, rotation: 9001 } }));

    let race = importChallengeDesk({
      challenge_desk: {
        actor_model,
        position,
        rotation
      }
    });

    assert.equal(race.challengeDesk.actorModel, actor_model);
    assert.deepEqual(race.challengeDesk.position, position);
    assert.equal(race.challengeDesk.rotation, rotation);
  });
});