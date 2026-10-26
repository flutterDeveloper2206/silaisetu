import { Module } from '@nestjs/common';
import { GarmentTemplatesController } from './garment-templates.controller';
import { GarmentTemplatesService } from './garment-templates.service';

@Module({
  controllers: [GarmentTemplatesController],
  providers: [GarmentTemplatesService],
  exports: [GarmentTemplatesService],
})
export class GarmentTemplatesModule {}
